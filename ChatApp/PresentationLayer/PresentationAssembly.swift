//
//  PresentationAssembly.swift
//  ChatApp
//
//  Created by Дмитрий Данилин on 18.05.2022.
//

import Foundation

final class PresentationAssembly {
    private let serviceAssembly = AssemblyService()
    
    var channelListVC: ChannelListViewController {
        return ChannelListViewController(
            channelListService: serviceAssembly.channelService
        )
    }
}
