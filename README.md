# DataTransformToCSV_Millitech

[데이터 변환을 위한 준비 과정]
1. matlab을 컴퓨터에 설치합니다.
2. Data Acquisition Toolbox 또는 Communications Toolbox를 설치합니다.
   >>MATLAB을 실행하고, 상단 메뉴에서 Home > Add-Ons > Get Add-Ons를 클릭합니다.
   >>검색창에 "Data Acquisition Toolbox"을 검색합니다.
   >>해당 툴박스를 찾아 설치를 진행합니다.
   >>"Communications Toolbox"도 검색해서 설치합니다.
3. 이 경로에 있는 세 개의 파일들을 다운로드합니다.
4. matlab에서 열기>열기를 누르고 다운받은 파일들을 차례대로 선택해서 엽니다.
<img width="348" height="191" alt="image" src="https://github.com/user-attachments/assets/f877fc73-4450-4089-9a1c-8fed6ce90d40" />

5. matlab 하단의 터미널 창을 열고, 원하는 동작을 지시합니다.
<img width="1881" height="485" alt="image" src="https://github.com/user-attachments/assets/84c833ed-5bfc-40ae-89de-8473e46ed5b4" />


--
<img width="1020" height="65" alt="image" src="https://github.com/user-attachments/assets/877996d1-8673-42ea-8afb-ddbb6d70b56b" />
--


[acoustic 데이터 변환 과정]
acofun.m 파일을 수정하거나 그대로 사용해 데이터를 변환할 수 있습니다.
상황에 맞게 acofun.m을 수정 후 아래 명령어를 터미널 창에 입력하세요.
``matlab
acofun(csv로 변환하고 싶은 파일 경로, 저장할 경로 및 파일명)
%예:acofun("C:Desktop\~~\aco.matlab","C:Desktop\~\aco.csv")
``

[current, temp 데이터 변환 과정]
convertTdmsToCsv.m 파일을 수정하거나 그대로 사용해 데이터를 변환할 수 있습니다.
상황에 맞게 convertTdmsToCsv.m을 수정 후 아래 명령어를 터미널 창에 입력하세요.
``matlab
convertTdmsToCsv(csv로 변환하고 싶은 파일 경로, 저장할 경로 및 파일명)
``

[vibration 데이터 변환 과정]
functionforvibration.m 파일을 수정하거나 그대로 사용해 데이터를 변환할 수 있습니다.
상황에 맞게 functionforvibration.m을 수정 후 아래 명령어를 터미널 창에 입력하세요.
``matlab
functionforvibration(csv로 변환하고 싶은 파일 경로, 저장할 경로 및 파일명)
``
