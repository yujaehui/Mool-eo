//
//  UIViewController+Extension.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/9/24.
//

import PhotosUI
import YPImagePicker

extension UIViewController {
    func presentPHPicker(delegate: PHPickerViewControllerDelegate, selectionLimit: Int) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = delegate
        self.present(picker, animated: true)
    }
    
    func presentYPImagePicker(completion: @escaping (YPImagePicker, [YPMediaItem], Bool) -> Void) {
        var config = YPImagePickerConfiguration()
        config.wordings.next = "전송"
        config.wordings.cancel = "취소"
        config.screens = [.library]
        config.startOnScreen = .library
        config.library.maxNumberOfItems = 3
        config.library.mediaType = .photo
        config.library.skipSelectionsGallery = true
        config.showsPhotoFilters = false
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { items, cancelled in
            completion(picker, items, cancelled)
        }
        self.present(picker, animated: true)
    }
}
