//
//  HapticClock.swift
//  Watch Vibration Test
//
//  Created by Dennis Moschina on 06.01.24.
//

import Foundation

protocol HapticClock {
    var onFire: () -> () { get set }
    
    func start()
    func stop()
}
