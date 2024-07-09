//
//  UIViewController+Extension.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/9/24.
//

import PhotosUI

extension UIViewController {
    func presentPHPicker(delegate: PHPickerViewControllerDelegate, selectionLimit: Int) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = selectionLimit
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = delegate
        self.present(picker, animated: true)
    }
}
