# Mool-eo! (물어!)

![물어 썸네일](https://github.com/user-attachments/assets/9443fbca-adb3-4403-839f-954d8ae3641d)

### 올인원 반려동물 앱: 용품 거래와 커뮤니티 소통을 한 번에 누리세요.

> 다양한 반려동물 용품을 쉽고 빠르게 판매 및 구매할 수 있으며, 커뮤니티에서 반려동물 이야기를 공유할 수 있는 앱입니다. 실시간 채팅과 이미지 전송 기능으로  소통을 원활하게 진행하고, 프로필 관리와 팔로우 기능으로 사용자 간 네트워크를 구축할 수 있습니다.
> 

---

# 📚 목차

1. [⭐️ 주요 기능](#features)
2. [📸 스크린샷](#screenshots)
   - [상품](#product)
   - [게시글](#post)
   - [채팅](#chatting)
   - [좋아요](#like)
   - [프로필](#profile)
   - [회원가입 및 로그인](#sign-up-and-sign-in)
3. [💻 개발 환경](#development-environment)
4. [📋 설계 패턴](#design-patterns)
   - [Input-Output Reactive MVVM](#input-output-reactive-mvvm)
   - [싱글턴 패턴](#singleton-pattern)
5. [🛠️ 기술 스택](#tech-stack)
6. [🚀 트러블 슈팅](#troubleshooting)
   - [클로저의 강한 참조로 인한 소켓 리소스 누수 해결](#troubleshooting1)
   - [이미지 다운샘플링으로 메모리 절약 및 서버 업로드 효율 개선](#troubleshooting2)
   - [RxSwift Single & Moya 기반 제네릭 네트워크 구조 설계](#troubleshooting3)
   - [RxSwift zip 기반 동시 네트워크 요청과 UI 최적화](#troubleshooting4)
7. [🗂️ 파일 디렉토리 구조](#file-directory-structure)

---

<h1 id="features">⭐️ 주요 기능</h1>

**1. 상품 등록 및 판매**

- **상품 등록**: 반려동물과 관련된 다양한 상품(장난감, 사료, 용품 등)을 손쉽게 등록할 수 있습니다.
- **판매 기능**: 판매자가 상품 정보를 등록하면 앱 내에서 구매자를 유치하고 거래를 진행할 수 있습니다.
- **카테고리별 검색**: 구매자는 상품을 카테고리(예: 사료, 장난감 등)를 통해 쉽게 찾아볼 수 있습니다.
- **상품 상세 정보**: 상품의 사진, 설명, 가격 등 상세 정보를 확인할 수 있습니다.

**2. 커뮤니티 게시판**

- **게시글 작성**: 반려동물의 사진, 사연, 또는 질문을 자유롭게 게시할 수 있습니다.
- **댓글 기능**: 다른 사용자의 게시글에 댓글을 남길 수 있습니다.

**3. 좋아요 기능**

- **상품 좋아요**: 관심 있는 상품에 좋아요를 눌러 저장할 수 있으며, 좋아요한 상품만 별도로 확인할 수 있습니다.
- **게시글 좋아요**: 관심 있는 게시글에 좋아요를 눌러 저장할 수 있으며, 좋아요한 게시글만 따로 볼 수 있습니다.

**4. 팔로우 기능**

- **팔로우 관리**: 관심 있는 사용자를 팔로우하거나, 팔로우를 취소할 수 있습니다.

**5. 채팅 및 이미지 전송**

- **실시간 채팅**: 판매자와 구매자 간 실시간 채팅을 통해 거래를 원활하게 진행할 수 있습니다.
- **이미지 전송**: 채팅 중에 상품 사진이나 반려동물의 이미지를 전송할 수 있습니다.

**6. 프로필 관리**

- **사용자 프로필 설정**: 닉네임, 프로필 사진, 간단한 자기소개 등을 설정할 수 있습니다.
- **프로필 정보 수정**: 언제든지 프로필 정보를 업데이트할 수 있습니다.
- **나의 활동 확인**: 내가 판매 중인 상품, 올린 게시글 등을 한눈에 볼 수 있는 프로필 페이지를 제공합니다.

---

<h1 id="screenshots">📸 스크린샷</h1>

<h2 id="product">상품</h2>

| 작성 전 | 카테고리 선택 | 작성 중 | 작성 후 | 
|-------------|---------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/adaa298b-8493-423c-bc48-ffd59ad0e12b" width="200"> | <img src="https://github.com/user-attachments/assets/ba37a18d-1bd7-4939-bd23-737f84c3db0b" width="200"> | <img src="https://github.com/user-attachments/assets/a5d7f8cf-a043-471d-8aab-6b98193ff368" width="200"> | <img src="https://github.com/user-attachments/assets/9026fe4c-b1f8-42f8-ad3d-0315e2b4e632" width="200"> |

| 리스트 | 디테일 | 결제 |
|-------------|---------------|----------------|
| <img src="https://github.com/user-attachments/assets/37cc9e87-922e-47f9-b06a-edc67c05861f" width="200"> | <img src="https://github.com/user-attachments/assets/27a1196a-77c6-45ba-9a06-3e98de1e8a11" width="200"> | <img src="https://github.com/user-attachments/assets/52e0a219-f801-4c4e-8fc1-151b9c7f2dca" width="200"> |

<h2 id="post">게시글</h2>

| 작성 전 | 작성 중 | 작성 후 | 수정 |
|-------------|---------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/5f9ad8bd-1337-496a-a8b6-bb8216b58291" width="200"> | <img src="https://github.com/user-attachments/assets/81d9744f-7a36-49f0-a24a-d810072cfe89" width="200"> | <img src="https://github.com/user-attachments/assets/5dd1c75b-1efb-4c2b-a572-90a960323dd1" width="200"> | <img src="https://github.com/user-attachments/assets/d2922585-cfd1-488b-b305-b14c77ed0d52" width="200"> |

| 리스트 | 디테일 | 댓글 입력 | 댓글 삭제 |
|-------------|---------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/1281c7ec-bb43-43ac-aba8-e833ef73078f" width="200"> | <img src="https://github.com/user-attachments/assets/6da84704-815d-4237-88cc-037562b5bebf" width="200"> | <img src="https://github.com/user-attachments/assets/8c3ebe53-257d-4707-9441-9e95058b8757" width="200"> | <img src="https://github.com/user-attachments/assets/d589537a-5827-476f-a9b4-1915e5716028" width="200"> | 

<h2 id="chatting">채팅</h2>

| 리스트 | 전송 전 | 입력 중 | 전송 후 | 이미지 디테일 |
|-------------|---------------|----------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/251a1949-5c33-4012-8021-3e874e7b6ed6" width="200"> | <img src="https://github.com/user-attachments/assets/001e1df3-bd35-4473-aca5-4f8cd0af712c" width="200"> | <img src="https://github.com/user-attachments/assets/3f2d2f02-7f26-4852-9c4f-280883909a02" width="200"> | <img src="https://github.com/user-attachments/assets/d15c9352-0e9f-4f47-8d50-7af98d8f22cd" width="200"> | <img src="https://github.com/user-attachments/assets/31f122f0-12cb-4335-9d50-60b9d09f873f" width="200"> |

<h2 id="like">좋아요</h2>

| 상품 좋아요 목록 | 게시글 좋아요 목록 |
|-------------|---------------|
| <img src="https://github.com/user-attachments/assets/e8bc2c6e-48af-4029-917a-47546a74c4e1" width="200"> | <img src="https://github.com/user-attachments/assets/46df208e-0915-45fe-8b09-696f6c283e7d" width="200"> | 

<h2 id="profile">프로필</h2>

| 다른 유저 프로필 | 유저 프로필 | 유저 프로필 상품 | 유저 프로필 게시글 | 유저 프로필 수정 |
|-------------|---------------|----------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/8ded68a2-3946-40fc-84cb-c1197875f175" width="200"> | <img src="https://github.com/user-attachments/assets/d00095b8-79ea-407a-8cc7-4ed05769f2ad" width="200"> | <img src="https://github.com/user-attachments/assets/c311e39d-cd61-41db-b9fc-65491897db6b" width="200"> | <img src="https://github.com/user-attachments/assets/ff3325b6-4559-46b9-9869-1aa5f3ce65c9" width="200"> | <img src="https://github.com/user-attachments/assets/f82451ca-6862-4f40-ae51-cb5dae6c44b2" width="200"> |

<h2 id="sign-up-and-sign-in">회원가입 및 로그인</h2>

| 아이디 입력 전 | 아이디 입력 후 | 중복 확인 실패 | 중복 확인 성공 |
|-------------|---------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/1656bb50-5157-4218-a401-010a93b09000" width="200"> | <img src="https://github.com/user-attachments/assets/c025655c-7248-4f46-bf3a-fa1d9d05e05a" width="200"> | <img src="https://github.com/user-attachments/assets/16a4aff7-fdc8-4059-90c7-428106efe75c" width="200"> | <img src="https://github.com/user-attachments/assets/f96155d0-0e75-427d-bcc3-c0fcc9c32129" width="200"> |

| 비밀번호 입력 전 | 비밀번호 입력 후 | 닉네임 입력 전 | 닉네임 입력 후 | 
|-------------|---------------|----------------|----------------|
| <img src="https://github.com/user-attachments/assets/3cc8a00e-843b-4be1-82fa-6ac1f28c6ec4" width="200"> | <img src="https://github.com/user-attachments/assets/c2db7785-ee31-457a-95ff-8934e9773b61" width="200"> | <img src="https://github.com/user-attachments/assets/e869ac30-cbd8-49c4-9be0-17510fb8aaf0" width="200"> | <img src="https://github.com/user-attachments/assets/2a905648-67b2-44cc-aa62-11f96e8cdb0e" width="200"> |

| 회원가입 성공 | 로그인 입력 전 | 로그인 입력 후 | 
|-------------|---------------|----------------|
| <img src="https://github.com/user-attachments/assets/9e275862-1efe-4dcc-92fc-30b7e0e68dce" width="200"> | <img src="https://github.com/user-attachments/assets/3d7431e9-e705-4651-a873-1b6cfdce6aee" width="200"> | <img src="https://github.com/user-attachments/assets/d240c15f-d8b8-4f38-a5fa-643143baa7d4" width="200"> | 
---

<h1 id="development-environment">💻 개발 환경</h1>

- **iOS SDK**: iOS 16.0 이상
- **Xcode**: 15.0 이상
- **Swift 버전**: 5.8 이상
- **서버 제공**: 외부 서비스에서 제공
- **API 통신 방식**: RESTful API 및 실시간 통신(Socket.IO)
- **기타 정보**: 서버 운영 방식 및 배포 환경은 제공된 API 문서를 기반으로 연동

---

<h1 id="design-patterns">📋 설계 패턴</h1>

- **Input-Output Reactive MVVM**: UI와 비즈니스 로직 분리
- **싱글턴 패턴**: 전역적으로 관리가 필요한 객체를 재사용하기 위해 사용

<h2 id="input-output-reactive-mvvm">Input-Output Reactive MVVM</h2>

UI와 비즈니스 로직의 분리, 명확한 데이터 흐름을 위해 **Input-Output 기반 MVVM 패턴**을 적용하였습니다.
RxSwift를 활용하여 View와 ViewModel 간의 데이터 바인딩과 반응형 프로그래밍을 구현했습니다.

### **적용 이유**

- **UI와 로직의 분리**: View는 UI 렌더링과 사용자 상호작용만 담당하고, 로직은 ViewModel에서 처리하여 역할을 명확히 분리합니다.
- **반응형 프로그래밍**: RxSwift를 사용해 View와 ViewModel 간의 데이터를 효율적으로 바인딩하고, 이벤트 흐름을 간소화했습니다.
- **유연성과 확장성**: Input-Output 구조로 데이터의 흐름을 명확히 정의하고, 테스트 가능성을 높였습니다.

### **구현 방식 (예제 코드)**

1. **Input과 Output 구조 정의**
    - Input: View에서 발생하는 사용자 이벤트(버튼 탭, 텍스트 입력 등)를 캡처
    - Output: ViewModel에서 처리된 데이터를 View로 전달
    
    ```swift
    struct Input {
        let id: Observable<String>
        let password: Observable<String>
        let loginButtonTap: Observable<Void>
    }
    
    struct Output {
        let loginValidation: Driver<Bool>
        let loginSuccessTrigger: Driver<Void>
        let authenticationErr: Driver<Void>
    }
    ```
    
2. **ViewModel의 Input-Output 변환**
    - Input 데이터를 처리하여 Output으로 변환하는 `transform` 메서드를 구현
    
    ```swift
    func transform(input: Input) -> Output {
        let loginValidation = BehaviorSubject<Bool>(value: false)
        let loginSuccessTrigger = PublishSubject<Void>()
        let authenticationErr = PublishSubject<Void>()
    
        input.id
            .combineLatest(input.password)
            .map { !$0.isEmpty && !$1.isEmpty }
            .bind(to: loginValidation)
            .disposed(by: disposeBag)
    
        input.loginButtonTap
            .withLatestFrom(Observable.combineLatest(input.id, input.password))
            .flatMapLatest { id, password in
                NetworkManager.shared.login(query: LoginQuery(email: id, password: password))
            }
            .subscribe(onNext: { result in
                switch result {
                case .success:
                    loginSuccessTrigger.onNext(())
                case .failure:
                    authenticationErr.onNext(())
                }
            })
            .disposed(by: disposeBag)
    
        return Output(
            loginValidation: loginValidation.asDriver(onErrorJustReturn: false),
            loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: ()),
            authenticationErr: authenticationErr.asDriver(onErrorJustReturn: ())
        )
    }
    ```
    
3. **View에서의 데이터 바인딩**
    - View와 ViewModel 간의 데이터 흐름을 RxSwift를 활용해 바인딩
    
    ```swift
    let output = viewModel.transform(input: input)
    
    output.loginValidation
        .drive(loginButton.rx.isEnabled)
        .disposed(by: disposeBag)
    
    output.loginSuccessTrigger
        .drive(onNext: { [weak self] in
            self?.navigateToMainScreen()
        })
        .disposed(by: disposeBag)
    ```
    
4. **ViewModelType 프로토콜**
    - 모든 ViewModel에서 일관된 구조를 유지하기 위해 `Input`, `Output`, `transform` 메서드를 포함한 기본 템플릿을 설정
    
    ```swift
    	protocol ViewModelType {
        var disposeBag: DisposeBag { get set }
        associatedtype Input
        associatedtype Output
        func transform(input: Input) -> Output
    }
    ```

<h2 id="singleton-pattern">싱글턴 패턴</h2>

전역적으로 관리가 필요한 객체들에 대해 **싱글턴 패턴**을 적용하여 일관성과 성능 최적화를 도모했습니다.

### **적용 이유**

- **일관된 전역 관리**: 동일한 인스턴스를 재사용하여 코드 일관성 유지
- **성능 최적화**: `DateFormatter`와 같은 비용이 큰 객체의 재사용을 통해 성능 향상
- **중복 방지**: 반복적인 리소스 초기화 방지 및 전역 접근 보장

---

<h1 id="tech-stack">🛠️ 기술 스택</h1>

### **기본 구성**

- **UIKit**: iOS 사용자 인터페이스 구성
- **SnapKit**: Auto Layout을 코드로 간단히 구현
- **Codebase UI**: 코드 기반으로 뷰를 설계하여 Storyboard 의존성을 제거
- **ComposableLayout**: UICollectionView 레이아웃 설계
- **Pagination**: 효율적인 데이터 로드 및 무한 스크롤 구현

### **비동기 처리 및 네트워크 통신**

- **Socket.IO**: 실시간 통신 지원
- **RxSwift / RxCocoa**: 반응형 프로그래밍을 위한 주요 라이브러리
- **RxDataSources**: RxSwift를 활용한 데이터 소스 관리
- **RxGesture**: 제스처 이벤트를 반응형으로 처리
- **Codable**: 네트워크 응답 데이터의 디코딩 및 인코딩을 통해 JSON 데이터 처리
- **Alamofire**: 네트워크 요청 관리
- **Moya**: Alamofire 기반 네트워크 계층 추상화
- **NetworkLoggerPlugin**: 네트워크 요청/응답 로깅
- **AuthInterceptor**: 인증 요청 헤더 자동 추가
- **IAMPort-iOS**: 결제 연동을 위한 라이브러리

### **데이터 관리**

- **Realm**: 경량 데이터베이스로 로컬 데이터 관리

### **UI 개선 및 사용자 경험**

- **Kingfisher**: 네트워크 이미지를 간편하게 로드 및 캐싱
- **Toast-Swift**: 사용자 피드백을 위한 간단한 알림 UI
- **Tabman**: 페이지 전환이 있는 UI 구성

---

<h1 id="troubleshooting">🚀 트러블 슈팅</h1>

<h2 id="troubleshooting1">클로저의 강한 참조로 인한 소켓 리소스 누수 해결</h2>

### **1. 문제 정의**

- 채팅방 진입 시마다 새로운 소켓 인스턴스가 생성되며, 이전 연결이 정상적으로 해제되지 않음
- 클로저 내부에서 self를 강하게 참조하면서 deinit이 호출되지 않아, 뷰가 메모리에서 해제되지 못하면서 발생
- 그 결과, 중복 데이터 수신, 리소스 낭비, 다중 연결로 인한 충돌 문제가 발생

### **2. 문제 해결**

- 클로저 내부에서 [weak self]를 사용하여 강한 참조 순환을 제거
- deinit에서 소켓 연결 해제 로직을 명시적으로 추가하여 리소스 정리
- 소켓이 더 이상 필요하지 않은 경우 명확하게 해제되도록 정리하는 프로세스 구축

### **3. 결과**

- 채팅방 뷰가 정상적으로 해제되어 소켓 리소스 누수 문제 해결
- 중복 연결 및 데이터 수신 문제가 사라지며 네트워크 처리의 안정성 향상
- 클로저 구조 개선을 통해 메모리 관리의 일관성과 예측 가능성 확보

<h2 id="troubleshooting2">이미지 다운샘플링으로 메모리 절약 및 서버 업로드 효율 개선</h2>

### **1. 문제 정의**

- 상품 등록 및 게시글 작성에서 이미지 업로드 시, 고해상도 이미지를 그대로 로드하면 메모리 사용량이 급격히 증가
- 또한 서버 업로드 시 파일 크기 제한(5MB)을 초과하는 경우가 많아, 통신이 실패하거나 지연되는 사례가 반복적으로 발생
- 단순히 이미지 크기를 50% 축소하는 방식은 작은 이미지의 해상도가 불필요하게 저하

### **2. 문제 해결**

- CGImageSourceCreateThumbnailAtIndex를 활용한 다운샘플링 기법을 도입하여 화면 크기에 최적화된 해상도로 변환
- 고해상도 이미지의 크기를 줄여 메모리 사용량 절감 및 서버 업로드 시 최적화된 크기로 변환
- DispatchGroup을 적용하여 여러 이미지를 비동기적으로 처리하여 UI 응답성 유지
- autoreleasepool을 활용하여 이미지 로딩 중 불필요한 메모리를 빠르게 해제

### **3. 결과**

- 이미지 로드 시 메모리 사용량을 192.3MB → 83.8MB로 약 56% 절감
- 다운샘플링 적용 후 이미지 용량이 평균 70~90% 감소, 서버 업로드 성공률 및 속도 크게 향상
- 이미지 수와 해상도에 관계없이 안정적인 업로드 흐름 및 앱 반응성 확보

<h2 id="troubleshooting3">RxSwift Single & Moya 기반 제네릭 네트워크 구조 설계</h2>

### **1. 문제 정의**

- 각 ViewModel에서 개별적으로 네트워크 요청을 처리하여 코드 중복 심화
- URL 구성, 디코딩, 에러 처리 방식이 제각각이라 유지보수와 디버깅이 어려운 구조로 이어짐

### **2. 문제 해결**

- NetworkManager를 싱글턴 패턴으로 설계해 네트워크 요청을 중앙 집중형으로 관리
- RxSwift의 Single을 활용하여 성공(onSuccess)과 실패(onError)를 명확하게 분리
  - 네트워크 요청이 단일 응답을 반환하며, onSuccess 또는 onError만 처리하면 되기 때문에 Single을 선택
  - Completable은 반환 값이 필요 없는 경우에 사용하고, Observable은 다중 이벤트 처리에 유용하지만 API 통신의 경우 불필요한 복잡성을 초래할 수 있어 배제
- Moya를 도입해 API 구성과 요청 흐름을 일관되게 관리
- 공통 요청 로직을 제네릭으로 캡슐화하여 재사용성을 높임

### **3. 결과**

- 중복 코드 감소로 전체 네트워크 코드의 간결성과 가독성 향상
- 새로운 API 추가 시 최소한의 코드 수정만으로 대응 가능, 확장성 확보
- 통일된 네트워크 처리 구조를 통해 디버깅 및 유지보수 효율 대폭 개선

<h2 id="troubleshooting4">RxSwift zip 기반 동시 네트워크 요청과 UI 최적화</h2>

### **1. 문제 정의**

- 프로필 화면에서는 사용자 정보, 상품 목록, 게시글 목록 등 여러 데이터를 서버에서 불러와야 하는데, 개별 요청을 순차적으로 처리하면서 응답 대기 시간이 길어지는 문제가 발생.
- 또한 UI가 여러 번 갱신되면서 불필요한 리렌더링이 발생하여 화면이 깜빡이거나 끊기는 듯한 사용자 경험 저하로 이어짐

### **2. 문제 해결**

- RxSwift의 Observable.zip을 활용하여 여러 API 요청을 병렬로 처리
- 모든 응답을 한 번에 모은 후 UI를 갱신하는 방식으로 전환
   - zip은 모든 요청이 완료된 이후에만 결과를 방출하므로, 불필요한 중간 UI 갱신을 방지
   - combineLatest는 하나의 요청만 완료돼도 UI가 갱신되므로 이번 케이스에 부적합
- UI 갱신 타이밍을 단일 지점으로 통합하여 렌더링 효율화

### **3. 결과**

- 모든 데이터를 병렬로 요청함으로써 전체 응답 대기 시간을 단축
- UI가 한 번만 갱신되도록 최적화되어 깜빡임 및 성능 저하 문제 해결
- 사용자 경험이 보다 부드럽고 안정적으로 개선, 데이터가 일관되게 표시되는 화면 흐름 구현

---

<h1 id="file-directory-structure">🗂️ 파일 디렉토리 구조</h1>

```
Mool-eo
 ┣ Assets.xcassets
 ┃ ┣ AccentColor.colorset
 ┃ ┃ ┗ Contents.json
 ┃ ┣ AppIcon.appiconset
 ┃ ┃ ┣ Contents.json
 ┃ ┃ ┗ Logo.jpg
 ┃ ┣ logo.imageset
 ┃ ┃ ┣ Contents.json
 ┃ ┃ ┣ Logo.jpg
 ┃ ┃ ┣ Logo@2x.jpg
 ┃ ┃ ┗ Logo@3x.jpg
 ┃ ┣ .DS_Store
 ┃ ┗ Contents.json
 ┣ Base
 ┃ ┣ BaseCollectionReusableView.swift
 ┃ ┣ BaseCollectionViewCell.swift
 ┃ ┣ BaseTableViewCell.swift
 ┃ ┣ BaseView.swift
 ┃ ┗ BaseViewController.swift
 ┣ Base.lproj
 ┃ ┣ LaunchScreen.storyboard
 ┃ ┗ Main.storyboard
 ┣ ChatList
 ┃ ┣ ChatListSectionModel.swift
 ┃ ┣ ChatListTableViewCell.swift
 ┃ ┣ ChatListView.swift
 ┃ ┣ ChatListViewController.swift
 ┃ ┗ ChatListViewModel.swift
 ┣ ChatRoom
 ┃ ┣ Cell
 ┃ ┃ ┣ ChatDateTableViewCell.swift
 ┃ ┃ ┣ ManyImageChatCollectionViewCell.swift
 ┃ ┃ ┣ MyChatTableViewCell.swift
 ┃ ┃ ┣ MyImageChatTableViewCell.swift
 ┃ ┃ ┣ MyThreeImageChatTableViewCell.swift
 ┃ ┃ ┣ MyTwoImageChatTableViewCell.swift
 ┃ ┃ ┣ OtherChatTableViewCell.swift
 ┃ ┃ ┣ OtherImageChatTableViewCell.swift
 ┃ ┃ ┣ OtherThreeImageChatTableViewCell.swift
 ┃ ┃ ┗ OtherTwoImageChatTableViewCell.swift
 ┃ ┣ ImageChat
 ┃ ┃ ┣ ImageChatCollectionViewCell.swift
 ┃ ┃ ┣ ImageChatView.swift
 ┃ ┃ ┣ ImageChatViewController.swift
 ┃ ┃ ┗ ImageChatViewModel.swift
 ┃ ┣ ChatRoomSectionModel.swift
 ┃ ┣ ChatRoomView.swift
 ┃ ┣ ChatRoomViewController.swift
 ┃ ┗ ChatRoomViewModel.swift
 ┣ Custom
 ┃ ┣ CustomImageView
 ┃ ┃ ┣ LargePostImageView.swift
 ┃ ┃ ┣ PostImageView.swift
 ┃ ┃ ┗ ProfileImageView.swift
 ┃ ┣ CustomLabel
 ┃ ┃ ┗ CustomLabel.swift
 ┃ ┣ CustomTextField
 ┃ ┃ ┗ CustomTextField.swift
 ┃ ┣ CustomTextView
 ┃ ┃ ┗ AutoResizableTextView.swift
 ┃ ┗ CustomView
 ┃ ┃ ┣ ChatContentView.swift
 ┃ ┃ ┣ LineView.swift
 ┃ ┃ ┣ OtherChatContentView.swift
 ┃ ┃ ┣ ProductTextFieldView.swift
 ┃ ┃ ┣ ProfileTextFieldView.swift
 ┃ ┃ ┣ WriteContentView.swift
 ┃ ┃ ┗ WriteContentWithImageView.swift
 ┣ DesignSystem
 ┃ ┣ ColorStyle.swift
 ┃ ┗ FontStyle.swift
 ┣ Extension
 ┃ ┣ String+Extension.swift
 ┃ ┣ UIButton.Configuration+Extension.swift
 ┃ ┣ UIColor+Extension.swift
 ┃ ┣ UIImage+Extension.swift
 ┃ ┣ UITextField+Extension.swift
 ┃ ┣ UIView+Extension.swift
 ┃ ┗ UIViewController+Extension.swift
 ┣ Join
 ┃ ┣ JoinFirstStep
 ┃ ┃ ┣ JoinView.swift
 ┃ ┃ ┣ JoinViewController.swift
 ┃ ┃ ┗ JoinViewModel.swift
 ┃ ┣ JoinSecondStep
 ┃ ┃ ┣ JoinSecondView.swift
 ┃ ┃ ┣ JoinSecondViewController.swift
 ┃ ┃ ┗ JoinSecondViewModel.swift
 ┃ ┣ JoinSuccess
 ┃ ┃ ┣ JoinSuccessView.swift
 ┃ ┃ ┣ JoinSuccessViewController.swift
 ┃ ┃ ┗ JoinSuccessViewModel.swift
 ┃ ┣ JoinThirdStep
 ┃ ┃ ┣ JoinThirdView.swift
 ┃ ┃ ┣ JoinThirdViewController.swift
 ┃ ┃ ┗ JoinThirdViewModel.swift
 ┃ ┗ .DS_Store
 ┣ LikeList
 ┃ ┣ EmptyView.swift
 ┃ ┣ LikeListSectionModel.swift
 ┃ ┗ LikeListViewController.swift
 ┣ LikePostList
 ┃ ┣ LikePostListView.swift
 ┃ ┣ LikePostListViewController.swift
 ┃ ┣ LikePostListViewModel.swift
 ┃ ┗ LikePostTableViewCell.swift
 ┣ LikeProductList
 ┃ ┣ LikeProductCollectionViewCell.swift
 ┃ ┣ LikeProductListView.swift
 ┃ ┣ LikeProductListViewController.swift
 ┃ ┗ LikeProductListViewModel.swift
 ┣ Login
 ┃ ┣ LoginBoxView.swift
 ┃ ┣ LoginView.swift
 ┃ ┣ LoginViewController.swift
 ┃ ┗ LoginViewModel.swift
 ┣ Manager
 ┃ ┣ AlertManager.swift
 ┃ ┣ DateFormatterManager.swift
 ┃ ┣ HashtagManager.swift
 ┃ ┣ NumberFormatterManager.swift
 ┃ ┣ ToastManager.swift
 ┃ ┣ TransitionManager.swift
 ┃ ┣ URLImageSettingManager.swift
 ┃ ┗ UserDefaultsManager.swift
 ┣ Network
 ┃ ┣ Model
 ┃ ┃ ┣ Chat
 ┃ ┃ ┃ ┣ ChatHistoryModel.swift
 ┃ ┃ ┃ ┗ ChatListModel.swift
 ┃ ┃ ┣ Comment
 ┃ ┃ ┃ ┗ CommentModel.swift
 ┃ ┃ ┣ Follow
 ┃ ┃ ┃ ┗ FollowModel.swift
 ┃ ┃ ┣ LikePost
 ┃ ┃ ┃ ┗ LikePostModel.swift
 ┃ ┃ ┣ LikeProduct
 ┃ ┃ ┃ ┗ LikeProductModel.swift
 ┃ ┃ ┣ Payment
 ┃ ┃ ┃ ┗ PaymentListModel.swift
 ┃ ┃ ┣ Post
 ┃ ┃ ┃ ┣ FilesModel.swift
 ┃ ┃ ┃ ┗ PostListModel.swift
 ┃ ┃ ┣ Profile
 ┃ ┃ ┃ ┣ OtherUserProfileModel.swift
 ┃ ┃ ┃ ┗ ProfileModel.swift
 ┃ ┃ ┣ User
 ┃ ┃ ┃ ┣ EmailModel.swift
 ┃ ┃ ┃ ┣ JoinModel.swift
 ┃ ┃ ┃ ┣ LoginModel.swift
 ┃ ┃ ┃ ┣ RefreshModel.swift
 ┃ ┃ ┃ ┗ WithdrawModel.swift
 ┃ ┃ ┗ .DS_Store
 ┃ ┣ Query
 ┃ ┃ ┣ Chat
 ┃ ┃ ┃ ┣ ChatProduceQuery.swift
 ┃ ┃ ┃ ┗ ChatSendQuery.swift
 ┃ ┃ ┣ Comment
 ┃ ┃ ┃ ┗ CommentQuery.swift
 ┃ ┃ ┣ LikePost
 ┃ ┃ ┃ ┗ LikePostQuery.swift
 ┃ ┃ ┣ LikeProduct
 ┃ ┃ ┃ ┗ LikeProductQuery.swift
 ┃ ┃ ┣ Payment
 ┃ ┃ ┃ ┗ PaymentQuery.swift
 ┃ ┃ ┣ Post
 ┃ ┃ ┃ ┣ FilesQuery.swift
 ┃ ┃ ┃ ┗ PostQuery.swift
 ┃ ┃ ┣ Profile
 ┃ ┃ ┃ ┗ ProfileEditQuery.swift
 ┃ ┃ ┣ User
 ┃ ┃ ┃ ┣ EmailQuery.swift
 ┃ ┃ ┃ ┣ JoinQuery.swift
 ┃ ┃ ┃ ┗ LoginQuery.swift
 ┃ ┃ ┗ .DS_Store
 ┃ ┣ Service
 ┃ ┃ ┣ ChatService.swift
 ┃ ┃ ┣ CommentService.swift
 ┃ ┃ ┣ FollowService.swift
 ┃ ┃ ┣ HashtagService.swift
 ┃ ┃ ┣ LikePostService.swift
 ┃ ┃ ┣ LikeProductService.swift
 ┃ ┃ ┣ PaymentService.swift
 ┃ ┃ ┣ PostService.swift
 ┃ ┃ ┣ ProfileService.swift
 ┃ ┃ ┗ UserService.swift
 ┃ ┣ .DS_Store
 ┃ ┣ APIKey.swift
 ┃ ┣ AuthInterceptor.swift
 ┃ ┣ HTTPHeader.swift
 ┃ ┗ NetworkManager.swift
 ┣ OtherUserProfile
 ┃ ┣ OtherUserProfileInfoCollectionViewCell.swift
 ┃ ┣ OtherUserProfileSectionModel.swift
 ┃ ┣ OtherUserProfileView.swift
 ┃ ┣ OtherUserProfileViewController.swift
 ┃ ┗ OtherUserProfileViewModel.swift
 ┣ PostDetail
 ┃ ┣ CommentTableViewCell.swift
 ┃ ┣ PostDetailSectionModel.swift
 ┃ ┣ PostDetailTableViewCell.swift
 ┃ ┣ PostDetailView.swift
 ┃ ┣ PostDetailViewController.swift
 ┃ ┣ PostDetailViewModel.swift
 ┃ ┣ PostDetailWithoutImageTableViewCell.swift
 ┃ ┗ PostImageCollectionViewCell.swift
 ┣ PostList
 ┃ ┣ PostListSectionModel.swift
 ┃ ┣ PostListTableViewCell.swift
 ┃ ┣ PostListView.swift
 ┃ ┣ PostListViewController.swift
 ┃ ┗ PostListViewModel.swift
 ┣ ProductCategory
 ┃ ┣ ProductCategoryTableViewCell.swift
 ┃ ┣ ProductCategoryView.swift
 ┃ ┣ ProductCategoryViewController.swift
 ┃ ┗ ProductCategoryViewModel.swift
 ┣ ProductDetail
 ┃ ┣ Cell
 ┃ ┃ ┣ ProductDetailTableViewCell.swift
 ┃ ┃ ┣ ProductImageTableViewCell.swift
 ┃ ┃ ┗ ProductInfoTableViewCell.swift
 ┃ ┣ Section
 ┃ ┃ ┗ ProductDetailSectionModel.swift
 ┃ ┣ ProductDetailView.swift
 ┃ ┣ ProductDetailViewController.swift
 ┃ ┗ ProductDetailViewModel.swift
 ┣ ProductList
 ┃ ┣ Cell
 ┃ ┃ ┣ ProdcutListTableViewCell.swift
 ┃ ┃ ┗ ProductCategoryCollectionViewCell.swift
 ┃ ┣ ProductListView.swift
 ┃ ┣ ProductListViewController.swift
 ┃ ┗ ProductListViewModel.swift
 ┣ ProductWeb
 ┃ ┣ ProductWebView.swift
 ┃ ┣ ProductWebViewController.swift
 ┃ ┗ ProductWebViewModel.swift
 ┣ ProfileEdit
 ┃ ┣ ProfileEditView.swift
 ┃ ┣ ProfileEditViewController.swift
 ┃ ┗ ProfileEditViewModel.swift
 ┣ ProfilePaymentList
 ┃ ┣ PaymentListSectionModel.swift
 ┃ ┣ ProfilePaymentListTableViewCell.swift
 ┃ ┣ ProfilePaymentListView.swift
 ┃ ┣ ProfilePaymentListViewController.swift
 ┃ ┗ ProfilePaymentListViewModel.swift
 ┣ ProfilePostList
 ┃ ┣ ProfilePostListView.swift
 ┃ ┣ ProfilePostListViewController.swift
 ┃ ┗ ProfilePostListViewModel.swift
 ┣ ProfileProductList
 ┃ ┣ ProfileProductListView.swift
 ┃ ┣ ProfileProductListViewController.swift
 ┃ ┗ ProfileProductListViewModel.swift
 ┣ Protocol
 ┃ ┣ Section.swift
 ┃ ┗ ViewModelType.swift
 ┣ Realm
 ┃ ┣ Chat.swift
 ┃ ┗ ChatRepository.swift
 ┣ Setting
 ┃ ┣ SettingInfoTableViewCell.swift
 ┃ ┣ SettingManagementTableViewCell.swift
 ┃ ┣ SettingSectionModel.swift
 ┃ ┣ SettingView.swift
 ┃ ┣ SettingViewController.swift
 ┃ ┗ SettingViewModel.swift
 ┣ Socket
 ┃ ┗ SocketIOManager.swift
 ┣ UserProfile
 ┃ ┣ Cell
 ┃ ┃ ┣ EmptyCollectionViewCell.swift
 ┃ ┃ ┣ UserProfileInfoCollectionViewCell.swift
 ┃ ┃ ┣ UserProfileMoreCollectionViewCell.swift
 ┃ ┃ ┣ UserProfilePostCollectionViewCell.swift
 ┃ ┃ ┗ UserProfileProductCollectionViewCell.swift
 ┃ ┣ Header
 ┃ ┃ ┗ HeaderCollectionReusableView.swift
 ┃ ┣ Section
 ┃ ┃ ┣ EmptySection.swift
 ┃ ┃ ┣ UserInfoSection.swift
 ┃ ┃ ┣ UserMoreSection.swift
 ┃ ┃ ┣ UserPostSection.swift
 ┃ ┃ ┣ UserProductSection.swift
 ┃ ┃ ┗ UserProfileSectionModel.swift
 ┃ ┣ UserProfileView.swift
 ┃ ┣ UserProfileViewController.swift
 ┃ ┗ UserProfileViewModel.swift
 ┣ WritePost
 ┃ ┣ WritePostContentView.swift
 ┃ ┣ WritePostImageCollectionViewCell.swift
 ┃ ┣ WritePostImageEditCollectionViewCell.swift
 ┃ ┣ WritePostView.swift
 ┃ ┣ WritePostViewController.swift
 ┃ ┗ WritePostViewModel.swift
 ┣ WriteProduct
 ┃ ┣ Section
 ┃ ┃ ┗ ProductImageSection.swift
 ┃ ┣ WriteProductContentView.swift
 ┃ ┣ WriteProductView.swift
 ┃ ┣ WriteProductViewController.swift
 ┃ ┗ WriteProductViewModel.swift
 ┣ .DS_Store
 ┣ AppDelegate.swift
 ┣ Info.plist
 ┣ Noti.swift
 ┣ SceneDelegate.swift
 ┗ ViewController.swift
```
