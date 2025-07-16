# DataTransformToCSV_Millitech

이 문서는 MATLAB을 이용하여 특정 데이터(`matlab`, TDMS)를 CSV 형식으로 변환하는 방법에 대한 가이드입니다.

## [데이터 변환을 위한 준비 과정]

데이터 변환 작업을 시작하기 전에 아래의 필수 준비 단계를 완료해야 합니다.

1.  **MATLAB 설치:**
    컴퓨터에 MATLAB 소프트웨어가 설치되어 있어야 합니다.

2.  **필수 툴박스 설치:**
    다음 두 가지 툴박스가 필요합니다.
    * **Data Acquisition Toolbox**
    * **Communications Toolbox**

    **설치 방법:**
    * MATLAB을 실행합니다.
    * 상단 메뉴에서 `Home` > `Add-Ons` > `Get Add-Ons`를 클릭합니다.
    * 검색창에 "Data Acquisition Toolbox"를 검색하여 해당 툴박스를 찾아 설치를 진행합니다.
    * 동일한 방법으로 "Communications Toolbox"도 검색하여 설치합니다.

3.  **필수 파일 다운로드:**
    변환 작업에 필요한 세 개의 MATLAB 스크립트 파일(`acofun.m`, `convertTdmsToCsv.m`, `functionforvibration.m`)을 다운로드합니다.
    *(참고: 파일 다운로드 경로는 본 가이드에 포함되어 있지 않습니다.)*

4.  **MATLAB에서 파일 열기:**
    * MATLAB을 실행합니다.
    * 메뉴에서 `열기(Open)` > `열기(Open)`를 클릭합니다.
    * 다운로드한 세 개의 `.m` 파일을 차례대로 선택하여 엽니다.

    ![MATLAB에서 파일 열기](image_7f2a61.png)

5.  **MATLAB 터미널(명령 창) 사용:**
    * MATLAB 하단에 있는 **터미널 창 (Command Window)**을 엽니다.
    * 이 창에 아래에서 설명할 데이터 변환 명령어를 입력하여 실행합니다.

    ![MATLAB 터미널 창](image_7f2a25.png)

---

![구분선](image_7f2a00.png)

---

## [데이터 변환 과정]

각 데이터 유형별로 변환에 사용되는 MATLAB 스크립트와 실행 명령어는 다음과 같습니다. 각 `.m` 파일은 상황에 맞게 내용을 수정하여 사용할 수도 있습니다.

### Acoustic 데이터 변환 (`acofun.m`)

`acofun.m` 파일을 사용하여 Acoustic 데이터를 CSV로 변환할 수 있습니다.

* **명령어 형식:**

    ```matlab
    acofun(csv로 변환하고 싶은 파일 경로, 저장할 경로 및 파일명)
    ```

* **예시:**

    ```matlab
    acofun("C:\Desktop\~~\aco.matlab", "C:\Desktop\~\aco.csv")
    ```

### Current, Temp 데이터 변환 (`convertTdmsToCsv.m`)

`convertTdmsToCsv.m` 파일을 사용하여 Current 및 Temp 데이터를 CSV로 변환할 수 있습니다. 이 함수는 TDMS 파일을 처리하는 데 사용됩니다.

* **명령어 형식:**

    ```matlab
    convertTdmsToCsv(csv로 변환하고 싶은 파일 경로, 저장할 경로 및 파일명)
    ```

### Vibration 데이터 변환 (`functionforvibration.m`)

`functionforvibration.m` 파일을 사용하여 Vibration 데이터를 CSV로 변환할 수 있습니다.

* **명령어 형식:**

    ```matlab
    functionforvibration(csv로 변환하고 싶은 파일 경로, 저장할 경로 및 파일명)
    ```
