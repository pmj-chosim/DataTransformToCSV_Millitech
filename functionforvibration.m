function functionforvibration(matFilePath, csvSavePath)
% 이 스크립트는 MATLAB .mat 파일에서 데이터를 로드하여 CSV 파일로 변환합니다.
% 모든 스칼라, 문자열, 작은 배열 및 중첩된 구조체 필드는 CSV 헤더로 펼쳐져
% 각 행에 반복적으로 포함되며, 주요 y_values.values 데이터는 마지막 열에 추가됩니다.

% 1. MATLAB 파일 로드 (여기서 .mat 파일의 경로를 정확히 지정해야 합니다.)
% 예시 경로: "C:\Users\parkm\Desktop\vibration\0Nm_BPFI_03.mat"
% 실제 파일 경로로 수정해주세요.
load(matFilePath); % <-- 이 부분을 동적으로 변경했습니다.

% 2. CSV 헤더 및 각 행에 반복될 데이터 추출 및 평탄화
% Signal 구조체에서 y_values.values를 제외한 나머지 부분을 평탄화
temp_y_values_values = Signal.y_values.values;
Signal.y_values.values = []; % 임시로 빈 값으로 설정하여 flatten 함수가 처리하지 않도록 함

% flatten_struct 함수 호출 (아래에 중첩 함수로 정의되어 있음)
[all_meta_headers, all_meta_values] = flatten_struct(Signal, '');

% 다시 원본 y_values.values 복원
Signal.y_values.values = temp_y_values_values;

% 3. CSV 파일 준비
csvFileName = csvSavePath; % <-- 이 부분을 동적으로 변경했습니다.
fid = fopen(csvFileName, 'w');

% 4. CSV 헤더 작성
% Time 열 추가
final_headers = {'Time_s'};

% 평탄화된 모든 메타데이터 헤더 추가
final_headers = [final_headers, all_meta_headers];

% y_values.values의 4개 열 헤더 추가 (예: g_Col1, g_Col2, g_Col3, g_Col4)
% y_values.quantity.label은 'g' 일 수 있습니다.
y_quantity_label = Signal.y_values.quantity.label;
final_headers = [final_headers, {sprintf('%s_Col1',y_quantity_label), ...
                                 sprintf('%s_Col2',y_quantity_label), ...
                                 sprintf('%s_Col3',y_quantity_label), ...
                                 sprintf('%s_Col4',y_quantity_label)}];

fprintf(fid, '%s\n', strjoin(final_headers, ','));

% 5. 데이터 쓰기
% 각 행에 대해 반복 (y_values.values의 행 개수만큼)
num_data_rows = size(Signal.y_values.values, 1);
x_start_value = Signal.x_values.start_value;
x_increment = Signal.x_values.increment;

for i = 1:num_data_rows
    % 현재 행의 Time 값 계산
    current_time = x_start_value + (i - 1) * x_increment;

    % 각 행의 데이터 셀 생성
    row_data_cells = cell(1, numel(final_headers));

    % Time 값
    row_data_cells{1} = num2str(current_time, '%f');

    % 평탄화된 모든 메타데이터 값 추가
    current_col_idx = 2; % Time 다음 열부터 시작
    for val_idx = 1:numel(all_meta_values)
        val = all_meta_values{val_idx};
        % 모든 'val'을 최종적으로 문자열로 변환하여 셀에 저장
        if isnumeric(val) % 숫자인 경우 문자열로
            row_data_cells{current_col_idx} = num2str(val, '%e'); 
        elseif ischar(val) % 문자열인 경우 그대로
            row_data_cells{current_col_idx} = val;
        else % 그 외 (예: 빈 셀 {} 같은 예외 처리)
            row_data_cells{current_col_idx} = ''; % 빈 문자열로 처리
        end
        current_col_idx = current_col_idx + 1;
    end

    % y_values.values의 4개 열 추가
    for col_idx = 1:4
        row_data_cells{current_col_idx} = num2str(Signal.y_values.values(i, col_idx), '%f');
        current_col_idx = current_col_idx + 1;
    end

    % 모든 셀을 쉼표로 연결하여 한 줄 출력
    fprintf(fid, '%s\n', strjoin(row_data_cells, ','));
end

% 6. 파일 닫기
fclose(fid);

disp(['CSV 파일이 성공적으로 생성되었습니다: ', csvFileName]);

% --- 중첩 함수 (Nested Function) 정의 ---
% 이 함수는 상위 함수 'functionforvibration' 내에서만 유효합니다.
function [flat_headers, flat_values] = flatten_struct(data_struct, prefix)
    if nargin < 2
        prefix = '';
    end

    flat_headers = {};
    flat_values = {};

    if isstruct(data_struct)
        fields = fieldnames(data_struct);
        for i = 1:length(fields)
            fieldName = fields{i};
            
            % 헤더 이름 생성 로직: 최상위는 'Signal_필드명', 그 외는 '상위_필드명_하위_필드명'
            if isempty(prefix)
                current_prefix_for_next_level = ['Signal_', fieldName, '_'];
                header_name_for_scalar = ['Signal_', fieldName];
            else
                current_prefix_for_next_level = [prefix, fieldName, '_'];
                if ~isempty(prefix) && endsWith(prefix, '_')
                    header_name_for_scalar = [prefix(1:end-1), '_', fieldName];
                else
                    header_name_for_scalar = [prefix, fieldName]; % 안전장치
                end
            end

            fieldValue = data_struct.(fieldName);

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
            elseif iscell(fieldValue) % 셀 배열 (예: function_record 내부의 name, type 등)
                for k = 1:numel(fieldValue) % 셀 배열의 각 요소를 별도 열로
                    cell_content = fieldValue{k};
                    header_name = [current_prefix_for_next_level, num2str(k)];
                    if ischar(cell_content)
                        flat_headers{end+1} = header_name;
                        flat_values{end+1} = {cell_content}; % <-- 사용자님 원본 코드대로 {} 다시 삽입
                    elseif isnumeric(cell_content) && isscalar(cell_content)
                        flat_headers{end+1} = header_name;
                        flat_values{end+1} = {num2str(cell_content)}; % <-- 사용자님 원본 코드대로 {} 다시 삽입
                    elseif isnumeric(cell_content) % 숫자 배열인 경우 (예: num, den)
                        flat_headers{end+1} = header_name;
                        flat_values{end+1} = {['"', mat2str(cell_content), '"']}; % <-- 사용자님 원본 코드대로 {} 다시 삽입
                    else % 기타 복합 타입은 JSON 문자열로 변환 시도
                        flat_headers{end+1} = header_name;
                        try
                            flat_values{end+1} = {['"', jsonencode(cell_content), '"']}; % <-- 사용자님 원본 코드대로 {} 다시 삽입
                        catch
                            flat_values{end+1} = {'N/A'}; % <-- 사용자님 원본 코드대로 {} 다시 삽입
                        end
                    end
                end
            elseif ischar(fieldValue) % 문자열
                flat_headers{end+1} = header_name_for_scalar;
                flat_values{end+1} = {fieldValue}; % <-- 사용자님 원본 코드대로 {} 다시 삽입
            elseif isnumeric(fieldValue) && isscalar(fieldValue) % 스칼라 숫자
                flat_headers{end+1} = header_name_for_scalar;
                flat_values{end+1} = {num2str(fieldValue, '%e')}; % <-- 사용자님 원본 코드대로 {} 다시 삽입
            elseif isnumeric(fieldValue) && ~isscalar(fieldValue) % 숫자 배열 (예: num, den)
                flat_headers{end+1} = header_name_for_scalar;
                flat_values{end+1} = {['"', mat2str(fieldValue), '"']}; % <-- 사용자님 원본 코드대로 {} 다시 삽입
            else % 기타 데이터 타입 (논리, 함수 핸들 등)
                flat_headers{end+1} = header_name_for_scalar;
                flat_values{end+1} = {'UNSUPPORTED_TYPE'}; % <-- 사용자님 원본 코드대로 {} 다시 삽입
            end
        end
    end
end

% --- 상위 함수 'functionforvibration'의 끝을 나타내는 end 키워드 ---
end % <<<<<< 이 'end' 키워드는 반드시 있어야 합니다.
