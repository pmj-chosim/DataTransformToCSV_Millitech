function acofun(matFilePath, csvFileName)
% 이 스크립트는 MATLAB .mat 파일에서 데이터를 로드하여 CSV 파일로 변환합니다.
% 모든 스칼라, 문자열, 작은 배열 및 중첩된 구조체 필드는 CSV 헤더로 펼쳐져
% 각 행에 반복적으로 포함되며, 주요 y_values.values 데이터는 마지막 열에 추가됩니다.
%
% 입력 변수:
%   matFilePath - 로드할 MATLAB .mat 파일의 전체 경로 (예: 'C:\data\signal.mat')
%   csvFileName - 생성될 CSV 파일의 이름 (예: 'output.csv')

% 1. MATLAB 파일 로드 (안전한 로드 방식 유지)
if nargin < 2
    error('Usage: acofun(matFilePath, csvFileName)');
end

try
    loadedData = load(matFilePath); 
catch ME
    error('Error loading .mat file: %s. Please check the file path and ensure it is a valid .mat file. Error: %s', matFilePath, ME.message);
end

if isfield(loadedData, 'Signal')
    Signal = loadedData.Signal; 
else
    error('Error: ''Signal'' field not found in the loaded .mat file. Available fields are: %s', strjoin(fieldnames(loadedData), ', '));
end

% 2. CSV 헤더 및 각 행에 반복될 데이터 추출 및 평탄화
% Signal 구조체에서 y_values.values를 제외한 나머지 부분을 평탄화
[all_meta_headers, all_meta_values] = flatten_struct(Signal, '');

% 3. CSV 파일 준비
fid = fopen(csvFileName, 'w');
if fid == -1
    error('Error: Could not open CSV file for writing: %s. Check file permissions or if the file is already open.', csvFileName);
end

% 4. CSV 헤더 작성
final_headers = {'Time_s'};
final_headers = [final_headers, all_meta_headers];

% <<<--- y_values.values의 열 개수를 1로 고정하여 헤더 추가 --->>>
% 사용자님의 acoustic 데이터 (3072000x1 double)에 맞춰 1열로 고정
num_y_cols_fixed = 1; 

% y_values.quantity.label 설정
y_quantity_label = 'Value'; 
if isfield(Signal.y_values, 'quantity') && isfield(Signal.y_values.quantity, 'label')
    y_quantity_label = char(Signal.y_values.quantity.label); 
end

for c_idx = 1:num_y_cols_fixed
    final_headers = [final_headers, {sprintf('%s_Col%d',y_quantity_label, c_idx)}];
end

% <<<--- 최종 헤더를 char 배열로 통일하여 strjoin에 전달 (강화된 로직) --->>>
% cellfun을 사용하여 final_headers의 모든 요소를 char 배열로 강제 변환
char_final_headers = cellfun(@(x) char(x), final_headers, 'UniformOutput', false);
fprintf(fid, '%s\n', strjoin(char_final_headers, ','));

% 5. 데이터 쓰기
num_data_rows = size(Signal.y_values.values, 1);
x_start_value = Signal.x_values.start_value;
x_increment = Signal.x_values.increment;

for i = 1:num_data_rows
    current_time = x_start_value + (i - 1) * x_increment;
    row_data_cells = cell(1, numel(final_headers)); % 전체 열 개수만큼 셀 배열 미리 할당
    
    row_data_cells{1} = num2str(current_time, '%.10f'); 

    current_col_idx = 2; 
    for val_idx = 1:numel(all_meta_values)
        val = all_meta_values{val_idx};
        % flatten_struct에서 이미 최종 char 배열 형태로 반환되므로 바로 사용
        row_data_cells{current_col_idx} = val; 
        current_col_idx = current_col_idx + 1;
    end
    
    % <<<--- y_values.values의 열 개수를 1로 고정하여 데이터 추가 --->>>
    for col_idx = 1:num_y_cols_fixed % 1로 고정
        % y_values.values가 실제 1열인지 확인하는 조건문 추가
        if col_idx <= size(Signal.y_values.values, 2)
            row_data_cells{current_col_idx} = num2str(Signal.y_values.values(i, col_idx), '%.10f');
        else
            row_data_cells{current_col_idx} = ''; % 열이 없는 경우 빈 문자열
        end
        current_col_idx = current_col_idx + 1;
    end
    
    % <<<--- 최종 row_data_cells를 char 배열로 통일하여 strjoin에 전달 (강화된 로직) --->>>
    % cellfun을 사용하여 row_data_cells의 모든 요소를 char 배열로 강제 변환
    char_row_data_cells = cellfun(@(x) char(x), row_data_cells, 'UniformOutput', false);
    fprintf(fid, '%s\n', strjoin(char_row_data_cells, ','));
end

% 6. 파일 닫기
fclose(fid);

disp(['CSV 파일이 성공적으로 생성되었습니다: ', csvFileName]);

% --- 중첩 함수 (Nested Function) 정의 ---
function [flat_headers, flat_values] = flatten_struct(data_struct, prefix)
    if nargin < 2
        prefix = '';
    end

    flat_headers = {};
    flat_values = {}; % 이 셀 배열의 모든 요소는 최종적으로 단일 문자열(char array)이어야 합니다.

    if isstruct(data_struct)
        fields = fieldnames(data_struct);
        for i = 1:length(fields)
            fieldName = fields{i};
            
            if isempty(prefix)
                current_prefix_for_next_level = ['Signal_', fieldName, '_'];
                header_name_for_scalar = ['Signal_', fieldName];
            else
                current_prefix_for_next_level = [prefix, fieldName, '_'];
                header_name_for_scalar = [prefix(1:end-1), '_', fieldName]; 
            end

            fieldValue = data_struct.(fieldName);

            % 시계열 데이터 (Signal.y_values.values 및 Signal.x_values.values)는 평탄화에서 제외
            % isscalar(fieldValue)를 사용하여 1x1 숫자 값은 평탄화 대상에 포함하고, 
            % 그 이상의 배열은 제외하도록 명확히 합니다.
            if (strcmp(header_name_for_scalar, 'Signal_y_values_values') || ...
                strcmp(header_name_for_scalar, 'Signal_x_values_values')) || ...
               (contains(header_name_for_scalar, '_values', 'IgnoreCase', true) && ... 
                (isnumeric(fieldValue) || islogical(fieldValue)) && numel(fieldValue) > 1) 
                continue; 
            end
            
            if isstruct(fieldValue) % 중첩된 구조체
                if numel(fieldValue) == 1 % 단일 구조체
                    [sub_headers, sub_values] = flatten_struct(fieldValue, current_prefix_for_next_level);
                    flat_headers = [flat_headers, sub_headers];
                    flat_values = [flat_values, sub_values];
                else % 1xN struct 배열 (예: quantity_terms) - 각 요소를 별도 열로
                    for k = 1:numel(fieldValue)
                        [sub_headers, sub_values] = flatten_struct(fieldValue(k), [current_prefix_for_next_level, num2str(k), '_']);
                        flat_headers = [flat_headers, sub_headers];
                        flat_values = [flat_values, sub_values];
                    end
                end
            elseif iscell(fieldValue) % 셀 배열
                for k = 1:numel(fieldValue) % 셀 배열의 각 요소를 별도 열로
                    cell_content = fieldValue{k};
                    header_name = [header_name_for_scalar, '_Cell', num2str(k)]; 
                    flat_headers{end+1} = header_name;
                    
                    try
                        % flat_values에 값을 할당할 때 char 배열의 행 벡터로 강제 변환
                        if ischar(cell_content) 
                            flat_values{end+1} = reshape(cell_content, 1, []); % char 배열을 1xN 행 벡터로
                        elseif isstring(cell_content)
                            flat_values{end+1} = char(reshape(cell_content, 1, [])); % string을 char 행 벡터로
                        elseif isnumeric(cell_content) || islogical(cell_content)
                            flat_values{end+1} = num2str(reshape(cell_content, 1, []), '%.10g'); % 숫자는 char 행 벡터로
                        elseif isempty(cell_content)
                            flat_values{end+1} = ''; % 빈 값은 빈 char 배열
                        else % 기타 복합 타입은 JSON 문자열로 변환 시도
                            try
                                % jsonencode는 string을 반환할 수 있으므로 char()로 감싸줍니다.
                                flat_values{end+1} = char(jsonencode(cell_content)); 
                            catch
                                flat_values{end+1} = 'UNSUPPORTED_CELL_TYPE'; 
                            end
                        end
                    catch ME
                        flat_values{end+1} = 'ERROR_FLAT_CELL_CONTENT';
                        warning('MATLAB:exportSignalToCSV:CellConversionError', ...
                                'Cell content conversion error for %s. Error: %s', header_name, ME.message);
                    end
                end
            elseif ischar(fieldValue) 
                flat_headers{end+1} = header_name_for_scalar;
                % flat_values에 값을 할당할 때 char 배열의 행 벡터로 강제 변환
                flat_values{end+1} = reshape(fieldValue, 1, []); % char 배열을 1xN 행 벡터로
            elseif isstring(fieldValue) 
                flat_headers{end+1} = header_name_for_scalar;
                % flat_values에 값을 할당할 때 char 배열의 행 벡터로 강제 변환
                flat_values{end+1} = char(reshape(fieldValue, 1, [])); % string을 char 행 벡터로
            elseif isnumeric(fieldValue) || islogical(fieldValue) 
                if numel(fieldValue) == 1 
                    flat_headers{end+1} = header_name_for_scalar;
                    % flat_values에 값을 할당할 때 char 배열의 행 벡터로 강제 변환
                    flat_values{end+1} = num2str(fieldValue, '%.10g'); 
                else % 숫자 배열 (시계열이 아닌 작은 배열, 예: 벡터, 행렬)
                     flat_headers{end+1} = header_name_for_scalar;
                     try
                        % mat2str은 char를 반환하므로 reshape만 적용
                        flat_values{end+1} = reshape(mat2str(fieldValue), 1, []); % 배열을 char 문자열로
                     catch
                        flat_values{end+1} = 'ARRAY_TO_STRING_ERROR';
                     end
                end
            elseif isempty(fieldValue) 
                flat_headers{end+1} = header_name_for_scalar;
                % flat_values에 값을 할당할 때 char 배열의 행 벡터로 강제 변환
                flat_values{end+1} = ''; % 빈 char 배열
            else 
                flat_headers{end+1} = header_name_for_scalar;
                try
                    % string() 변환 후 char()로 감싸서 char 배열로 만듭니다.
                    flat_values{end+1} = char(string(fieldValue)); 
                catch ME
                    flat_values{end+1} = 'UNSUPPORTED_TYPE_FIELD'; 
                    warning('MATLAB:exportSignalToCSV:UnsupportedTypeError', ...
                            'Unsupported field type for %s. Error: %s', header_name_for_scalar, ME.message);
                end
            end
        end
    end
end
% --- 상위 함수 'exportSignalToCSV'의 끝을 나타내는 end 키워드 ---
end