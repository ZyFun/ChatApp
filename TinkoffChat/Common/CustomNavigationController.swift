//
//  CustomNavigationController.swift
//  TinkoffChat
//
//  Created by Дмитрий Данилин on 14.03.2022.
//

import UIKit

/// Используется для того, чтобы была возможность менять цвет статус бара в ручную через код
final class CustomNavigationController: UINavigationController {
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
