function convertTdmsToCsv(tdmsFilePath, csvSavePath)
%convertTdmsToCsv TDMS 파일을 읽어들여 지정된 CSV 경로에 저장합니다.
%
%   convertTdmsToCsv(tdmsFilePath, csvSavePath)
%
%   tdmsFilePath: 읽어들일 TDMS 파일의 전체 경로 (예: 'C:/data/input.tdms')
%   csvSavePath:  저장할 CSV 파일의 전체 경로 (예: 'C:/output/data.csv')
%
%   주의: 이 함수는 MATLAB R2022a 이상 버전과 Data Acquisition Toolbox가 필요합니다.

    try
        % 1. TDMS 파일을 읽어들입니다.
        % tdmsread는 보통 셀 배열을 반환하며, 실제 데이터는 그 안에 테이블 형태로 있을 확률이 높습니다.
        rawData = tdmsread(tdmsFilePath);

        % 2. 실제 데이터가 담긴 테이블을 찾습니다.
        % 이미지에서 data{1,2}에 데이터가 있었으므로, 이를 가정합니다.
        % 만약 다른 위치에 있다면 이 부분을 수정해야 합니다.
        if iscell(rawData) && numel(rawData) >= 2 && istable(rawData{1,2})
            dataToSave = rawData{1,2};
            disp(['TDMS 파일에서 ' num2str(size(dataToSave, 1)) 'x' num2str(size(dataToSave, 2)) ' 크기의 테이블 데이터를 찾았습니다.']);
        elseif istable(rawData) % 경우에 따라 rawData 자체가 테이블일 수도 있습니다.
            dataToSave = rawData;
            disp(['TDMS 파일이 단일 테이블로 구성되어 있습니다: ' num2str(size(dataToSave, 1)) 'x' num2str(size(dataToSave, 2)) ' 크기.']);
        else
            error('변환할 테이블 데이터를 TDMS 파일에서 찾을 수 없거나 예상치 못한 형식입니다.');
        end

        % 3. 테이블 데이터를 CSV 파일로 저장합니다.
        writetable(dataToSave, csvSavePath);

        disp(['성공적으로 TDMS 파일을 CSV로 변환하여 다음 위치에 저장했습니다: ' csvSavePath]);

    catch ME
        % 오류 처리
        if strcmp(ME.identifier, 'MATLAB:UndefinedFunction')
            disp('오류: tdmsread 함수를 찾을 수 없습니다.');
            disp('Data Acquisition Toolbox가 설치되어 있는지 확인하거나 MATLAB 버전을 확인하세요 (R2022a 이상 필요).');
            disp('자세한 오류 메시지:');
            disp(ME.message);
        else
            disp(['TDMS 파일 변환 중 오류가 발생했습니다: ' ME.message]);
            disp(['오류 식별자: ' ME.identifier]);
        end
    end
end