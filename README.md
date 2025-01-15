# Mool-eo! (물어!)

![물어 썸네일](https://github.com/user-attachments/assets/9443fbca-adb3-4403-839f-954d8ae3641d)

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
   - [이미지 다운샘플링과 메모리 최적화로 서버 업로드 문제 해결](#image-downsampling-and-memory-optimization)
   - [테이블뷰와 키보드 충돌 해결: IQKeyboardManager 대안 구현](#tableview-keyboard-conflict-resolution)
   - [소켓 연결 안정성과 메모리 관리: 채팅 화면 최적화 사례](#socket-connection-and-memory-management)
7. [🗂️ 파일 디렉토리 구조](#file-directory-structure)
8. [🛣️ 향후 계획](#future-plans)

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

<h2 id="sign up and sign in">회원가입 및 로그인</h2>

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
    

### **향후 계획**

- RxSwift의 더 깊은 활용을 통해 복잡한 비동기 작업도 간단히 처리할 수 있도록 확장 예정
- ViewModel의 Output을 테스트하는 자동화된 단위 테스트 작성
- DI(Dependency Injection)와의 결합으로 ViewModel 간 의존성 관리 개선

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

### **비동기 처리 및 네트워크 통신**

- **Socket.IO**: 실시간 통신 지원
- **RxSwift / RxCocoa**: 반응형 프로그래밍을 위한 주요 라이브러리
- **RxDataSources**: RxSwift를 활용한 데이터 소스 관리
- **RxGesture**: 제스처 이벤트를 반응형으로 처리
- **Alamofire**: 네트워크 요청 관리
- **Moya**: Alamofire 기반 네트워크 계층 추상화
- **Codable**: 네트워크 응답 데이터 디코딩 및 인코딩
- **NetworkLoggerPlugin**: 네트워크 요청/응답 로깅
- **AuthInterceptor**: 인증 요청 헤더 자동 추가

### **데이터 관리**

- **Realm**: 경량 데이터베이스로 로컬 데이터 관리

### **UI 개선 및 사용자 경험**

- **IAMPort-iOS**: 결제 연동을 위한 라이브러리
- **Kingfisher**: 네트워크 이미지를 간편하게 로드 및 캐싱
- **Toast-Swift**: 사용자 피드백을 위한 간단한 알림 UI
- **Tabman**: 페이지 전환이 있는 UI 구성

---

<h1 id="troubleshooting">🚀 트러블 슈팅</h1>

<h2 id="image-downsampling-and-memory-optimization">이미지 다운샘플링과 메모리 최적화로 서버 업로드 문제 해결</h2>

### **1. 문제 요약**

- **이슈 제목:** 원본 이미지 로딩 및 서버 업로드 시 메모리 사용량 증가 및 업로드 실패 문제
- **발생 위치:** 상품 목록, 게시글 목록, 상품 업로드, 게시글 업로드, 채팅 등
- **관련 컴포넌트:** 이미지 로딩, 이미지 서버 업로드, 메모리 관리 (`autoreleasepool`)

### **2. 문제 상세**

- **현상 설명:**
    - 원본 이미지를 그대로 불러와 처리할 때, 메모리 사용량이 급격히 증가하며, 서버 업로드 시 이미지 크기의 총합이 5MB를 초과할 경우 통신이 실패하는 문제가 발생.
    - 단순히 이미지 크기를 50%로 줄이는 방법으로는 이미지 총합 5MB 제한을 초과할 가능성이 여전히 존재하며, 작은 이미지도 불필요하게 화질이 감소됨.
- **추가 문제:**
    - 메모리 사용량이 많은 이미지 작업 중 메모리 관리가 부족하여 앱이 메모리 부족으로 충돌할 위험이 있었음.

### **3. 기존 코드 및 원인 분석**

- **기존 코드:**
    
    ```swift
    extension WriteProductViewController: PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // 기존 선택 초기화
            self.selectedImage.removeAll()
            self.selectedImageData.removeAll()
    
            for result in results {
                let itemProvider = result.itemProvider
                if itemProvider.canLoadObject(ofClass: UIImage.self) {
                    itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                        if let image = image as? UIImage {
                            DispatchQueue.main.async {
                                self.selectedImage.append(image)
                                self.selectedImageSubject.onNext(self.selectedImage)
                            }
    
                            if let imageData = image.pngData() {
                                print("Original image size: \\(imageData.count / 1024) KB")
                                self.selectedImageData.append(imageData)
                                self.selectedImageDataSubject.onNext(self.selectedImageData)
                            }
                        }
                    }
                }
            }
            picker.dismiss(animated: true)
        }
    }
    
    ```
    
- **원인 분석:**
    - 원본 이미지를 그대로 로드하고 처리할 때 고해상도 이미지가 메모리를 과다하게 사용하게 되며, 서버로 이미지를 전송할 때 총합이 5MB를 초과할 가능성이 큼.
    - 또한, 메모리 관리 측면에서 큰 이미지를 계속해서 메모리에 로드하면 메모리 사용량이 급격히 증가해 메모리 부족 문제를 초래할 수 있음.

## **4. 해결 방법 및 수정된 코드**

- **해결 방법:**
    - **다운샘플링 적용 및 메모리 관리 최적화**
        - 이미지를 원본 크기 그대로 사용하는 것이 아닌, 이미지뷰의 크기에 맞춰 다운샘플링을 적용하여 메모리 사용량을 줄임.
        - 이미지 처리 시에 `autoreleasepool`을 적절히 사용하여 메모리 해제를 신속하게 유도하고, 메모리 누수를 방지함.
        - 다운샘플링된 이미지를 통해 화질 저하를 최소화하면서도 업로드 시 서버의 5MB 제한을 넘지 않도록 최적화.
- **수정된 코드:**
    
    ```swift
    extension UIImage {
        func downsample(to pointSize: ImageViewSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageData = self.pngData() else { return nil }
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return nil }
    
            let maxDimensionInPixels = max(pointSize.getSize().width, pointSize.getSize().height) * scale
            let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
            ] as CFDictionary
    
            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return nil }
            return UIImage(cgImage: downsampledImage)
        }
    }
    ```
    
    ```swift
    extension WriteProductViewController: PHPickerViewControllerDelegate {
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
    
                // 기존 선택 초기화
                self.selectedImage.removeAll()
                self.selectedImageData.removeAll()
    
                let group = DispatchGroup()
    
                for result in results {
                    group.enter()
                    let itemProvider = result.itemProvider
                    if itemProvider.canLoadObject(ofClass: UIImage.self) {
                        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                            defer { group.leave() }
    
                            guard let self = self, let image = image as? UIImage else { return }
    
                            autoreleasepool {
                                if let downsampledImage = image.downsample(to: .screenWidth),
                                   let downsampleImageData = downsampledImage.pngData() {
                                    DispatchQueue.main.async {
                                        print("Downsampled image size: \\(downsampleImageData.count / 1024) KB")
                                        self.selectedImage.append(downsampledImage)
                                        self.selectedImageSubject.onNext(self.selectedImage)
                                        self.selectedImageData.append(downsampleImageData)
                                        self.selectedImageDataSubject.onNext(self.selectedImageData)
                                    }
                                }
                            }
                        }
                    } else {
                        group.leave()
                    }
                }
    
                group.notify(queue: .main) {
                    picker.dismiss(animated: true)
                }
            }
        }
    }
    ```

### **5. 결론**

- **메모리 최적화:**
    - 다운샘플링과 `autoreleasepool`을 적절히 사용하여 메모리 사용량을 크게 줄임.
- **업로드 최적화:**
    - 다운샘플링된 이미지는 서버 업로드 시 5MB 제한을 넘지 않도록 최적화되었고, 필요 이상의 화질 저하를 방지함.
- **최종 결과:**
    - 앱의 메모리 사용량이 안정적으로 관리되며, 서버와의 통신 문제를 해결하여 안정적인 이미지 업로드 및 처리를 보장.

<h2 id="tableview-keyboard-conflict-resolution">테이블뷰와 키보드 충돌 해결: IQKeyboardManager 대안 구현</h2>

### **1. 문제 요약**

- **이슈 제목:** IQKeyboardManager 사용 시 테이블뷰가 상단까지 스크롤되지 않는 문제
- **발생 위치:** 게시글 화면, 채팅 화면
- **관련 컴포넌트:** IQKeyboardManager, `UITableView`, 키보드 처리

### **2. 문제 상세**

- **현상 설명:**
    - IQKeyboardManager 오픈소스를 사용하여 키보드 활성화 시 자동으로 `UITextField`와 `UITableView`의 위치를 조정하였으나, 테이블뷰가 상단까지 스크롤되지 않는 문제가 발생. 이는 IQKeyboardManager가 키보드의 높이에 맞춰 테이블뷰의 `contentInset`과 `scrollIndicatorInsets`를 자동으로 조정하기 때문임.

### **3. 기존 코드 및 원인 분석**

- **기존 코드:**
    - IQKeyboardManager 사용
- **원인 분석:**
    - IQKeyboardManager는 키보드가 나타날 때 화면의 텍스트 필드 또는 텍스트 뷰가 가려지지 않도록 자동으로 화면을 조정해 주지만, 테이블뷰의 `contentInset`을 키보드 높이에 맞춰 자동으로 조정하면서 예상치 못한 스크롤 동작이 발생. 이로 인해 테이블뷰가 상단까지 스크롤되지 않음.

### **4. 해결 방법 및 수정된 코드**

- **해결 방법:**
    - **NotificationCenter를 활용한 수동 처리**
        - IQKeyboardManager 대신 `NotificationCenter`를 통해 키보드가 나타나고 사라질 때 발생하는 노티피케이션을 수신하여, 직접 키보드 높이에 맞춰 테이블뷰 및 UI 요소의 위치를 수동으로 조정.
    - **키보드 높이에 맞춰 UI 업데이트:**
        - 키보드의 높이를 얻어와 `tableView` 및 `writeMessageView`의 위치를 수동으로 업데이트하여 UI가 적절히 표시되도록 처리.
    - **애니메이션 적용:**
        - 키보드가 나타나거나 사라질 때 UI가 자연스럽게 전환되도록 0.3초의 애니메이션을 적용하여 사용자 경험을 개선.
- **수정된 코드:**
    
    ```swift
    final class ChatRoomViewController: BaseViewController {
    
        // 관련 없는 코드는 생략
    
        override func bind() {
            let input = ChatRoomViewModel.Input(
                keyboardWillShow: NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification),
                keyboardWillHide: NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification),
            )
    
            let output = viewModel.transform(input: input)
    
            output.keyboardWillShow.bind(with: self) { owner, notification in
                owner.keyboardWillShow(notification: notification)
            }.disposed(by: disposeBag)
    
            output.keyboardWillHide.bind(with: self) { owner, notification in
                owner.keyboardWillHide(notification: notification)
            }.disposed(by: disposeBag)
        }
    }
    
    extension ChatRoomViewController {
        private func keyboardWillShow(notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let keyboardHeight = keyboardFrame.height
    
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                // 테이블뷰와 메시지 입력 뷰의 위치를 업데이트
                self.chatRoomView.tableView.snp.updateConstraints { make in
                    make.top.horizontalEdges.equalTo(self.chatRoomView.safeAreaLayoutGuide)
                    make.bottom.equalTo(self.chatRoomView.writeMessageView.snp.top).offset(-10)
                }
    
                self.chatRoomView.writeMessageView.snp.updateConstraints { make in
                    make.horizontalEdges.equalTo(self.chatRoomView.safeAreaLayoutGuide)
                    make.bottom.equalToSuperview().inset(keyboardHeight) // 키보드 높이에 맞춰 메시지 입력 뷰 위치 조정
                }
                self.view.layoutIfNeeded()
            }
        }
    
        private func keyboardWillHide(notification: Notification) {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                // 키보드가 사라질 때 기본 위치로 복구
                self.chatRoomView.tableView.snp.updateConstraints { make in
                    make.top.horizontalEdges.equalTo(self.chatRoomView.safeAreaLayoutGuide)
                    make.bottom.equalTo(self.chatRoomView.writeMessageView.snp.top).offset(-10)
                }
    
                self.chatRoomView.writeMessageView.snp.updateConstraints { make in
                    make.horizontalEdges.equalTo(self.chatRoomView.safeAreaLayoutGuide)
                    make.bottom.equalToSuperview().inset(10) // 기본 여백으로 복구
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    ```

### **5. 결론**

- **IQKeyboardManager 제거:**
    - 오픈소스를 사용하지 않고 `NotificationCenter`를 활용하여 키보드가 나타나고 사라질 때 UI를 수동으로 조정함으로써 스크롤뷰 상단 문제를 해결.
- **테이블뷰와 메시지 입력 뷰의 위치 수동 조정:**
    - 키보드 높이에 맞춰 테이블뷰와 입력 뷰의 위치를 동적으로 변경하여, 예상치 못한 스크롤 이슈를 해결하고 안정적인 레이아웃을 유지.
- **최종 결과:**
    - 스크롤뷰가 정상적으로 상단까지 스크롤되며, 키보드가 화면에 나타날 때 UI가 정상적으로 조정됨.

<h2 id="socket-connection-and-memory-management">소켓 연결 안정성과 메모리 관리: 채팅 화면 최적화 사례</h2>

### **1. 문제 요약**

- **이슈 제목:** 채팅 화면에서 소켓 연결 해제 문제로 다중 연결 발생
- **발생 위치:** 채팅 화면에서 소켓 연결 및 해제 처리
- **관련 컴포넌트:** 소켓 연결, `deinit`, 강한 참조 (`strong reference`)

### **2. 문제 상세**

- **현상 설명:**
    - 채팅 화면을 나갔다가 다시 들어오면 소켓 연결이 끊기지 않고 계속 유지되면서 중복 연결되는 문제가 발생. 이로 인해 한 번 보낸 메시지가 두 번, 세 번씩 전송되는 현상이 나타남.
    - 채팅 화면이 닫힐 때 소켓 연결을 해제하기 위해 `deinit`에서 소켓 연결 해제를 호출했으나, 디버깅 결과 `deinit`이 호출되지 않음.

### **3. 기존 코드 및 원인 분석**

- **기존 코드:**
    - IQKeyboardManager 사용
    
    ```swift
    final class ChatRoomViewController: BaseViewController {
    
    		// 관련 없는 코드는 생략
    
        deinit {
            SocketIOManager.shared.leaveConnection() // 소켓 연결 해제
        }
    }
    
    extension ChatRoomViewController {
        private func configureDataSource() -> RxTableViewSectionedReloadDataSource<ChatRoomSectionModel> {
            return RxTableViewSectionedReloadDataSource<ChatRoomSectionModel>(
                configureCell: { dataSource, tableView, indexPath, item in // 강한 참조
                    if indexPath.row == 0 {
                        return self.configureHeaderCell(dataSource, tableView: tableView, indexPath: indexPath)
                    } else {
                        return self.configureChatCell(dataSource, tableView: tableView, indexPath: indexPath, item: item)
                    }
                }
            )
        }
    }
    ```
    
- **원인 분석:**
    - `deinit`에서 소켓 연결 해제를 호출했으나, 테이블뷰의 셀 구성 함수에서 강한 참조로 인해 `ChatRoomViewController`가 메모리에서 해제되지 않아 `deinit`이 호출되지 않음.
    - IQKeyboardManager 사용할 경우, 텍스트필드가 활성화된 채로 화면을 나가면 해당 뷰컨트롤러가 계속 메모리에 남아있게 됨.

### **4. 해결 방법 및 수정된 코드**

- **해결 방법:**
    - **약한 참조 적용:**
        - 테이블뷰의 셀 구성 부분에서 `weak self`를 사용하여 강한 참조로 인한 메모리 누수를 방지하고, 뷰컨트롤러가 정상적으로 해제될 수 있도록 수정.
    - **수동으로 키보드 활성화 및 해제 처리:**
        - `NotificationCenter`를 통해 키보드 활성화 및 해제 시점에 UI 조정을 수동으로 처리.
- **수정된 코드:**
    
    ```swift
    final class ChatRoomViewController: BaseViewController {
    
    		// 관련 없는 코드는 생략
    
        deinit {
            SocketIOManager.shared.leaveConnection() // 소켓 연결 해제
        }
    
        override func bind() {
            let input = ChatRoomViewModel.Input(
                keyboardWillShow: NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification),
                keyboardWillHide: NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification),
            )
    
            let output = viewModel.transform(input: input)
    
            output.keyboardWillShow.bind(with: self) { owner, notification in
                owner.keyboardWillShow(notification: notification)
            }.disposed(by: disposeBag)
    
            output.keyboardWillHide.bind(with: self) { owner, notification in
                owner.keyboardWillHide(notification: notification)
            }.disposed(by: disposeBag)
        }
    }
    
    extension ChatRoomViewController {
        private func keyboardWillShow(notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let keyboardHeight = keyboardFrame.height
    
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.chatRoomView.tableView.snp.updateConstraints { make in
                    make.top.horizontalEdges.equalTo(self.chatRoomView.safeAreaLayoutGuide)
                    make.bottom.equalTo(self.chatRoomView.writeMessageView.snp.top).offset(-10)
                }
    
                self.chatRoomView.writeMessageView.snp.updateConstraints { make in
                    make.horizontalEdges.equalTo(self.chatRoomView.safeAreaLayoutGuide)
                    make.bottom.equalToSuperview().inset(keyboardHeight)
                }
                self.view.layoutIfNeeded()
            }
        }
    
        private func keyboardWillHide(notification: Notification) {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.chatRoomView.tableView.snp.updateConstraints { make in
                    make.top.horizontalEdges.equalTo(self.chatRoomView.safeAreaLayoutGuide)
                    make.bottom.equalTo(self.chatRoomView.writeMessageView.snp.top).offset(-10)
                }
    
                self.chatRoomView.writeMessageView.snp.updateConstraints { make in
                    make.horizontalEdges.equalTo(self.chatRoomView.safeAreaLayoutGuide)
                    make.bottom.equalToSuperview().inset(10)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
    
    extension ChatRoomViewController {
        private func configureDataSource() -> RxTableViewSectionedReloadDataSource<ChatRoomSectionModel> {
            return RxTableViewSectionedReloadDataSource<ChatRoomSectionModel>(
                configureCell: { [weak self] dataSource, tableView, indexPath, item in
                    guard let self = self else { return UITableViewCell() }
                    if indexPath.row == 0 {
                        return self.configureHeaderCell(dataSource, tableView: tableView, indexPath: indexPath)
                    } else {
                        return self.configureChatCell(dataSource, tableView: tableView, indexPath: indexPath, item: item)
                    }
                }
            )
        }
    }
    ```

### **5. 결론**

- **강한 참조 해결:**
    - `weak self`를 사용하여 강한 참조 문제를 해결하고, 메모리 누수를 방지하여 `deinit`이 정상적으로 호출되도록 수정.
- **소켓 연결 해제 문제 해결:**
    - `deinit`이 정상적으로 호출되면서 소켓 연결 해제가 제대로 수행되고, 채팅 화면을 나갔다가 다시 들어와도 중복 연결되지 않도록 문제 해결.
- **IQKeyboardManager 제거 및 수동 UI 조정:**
    - IQKeyboardManager 대신 NotificationCenter를 사용하여 키보드 관련 UI 조정을 수동으로 처리함으로써 메모리 누수를 방지.

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

---

<h1 id="future-plans">🛣️ 향후 계획</h1>
