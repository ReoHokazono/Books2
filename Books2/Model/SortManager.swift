//
//  SortManager.swift
//  Books2
//
//  Created by 外園玲央 on 2020/11/15.
//

import Foundation

class SortManager: ObservableObject {
    
    enum SortAscending: String, CaseIterable, Identifiable {
        case firstItem, secondItem
        var id: String { rawValue }
    }
    
    enum SortKey: String, CaseIterable, Identifiable {
        case addedDate, title, contributor, defaultSort
        var id: String { rawValue }
    }

    @Published var sortAscending: SortAscending = .firstItem {
        didSet {
            let ascending:Bool = {
                switch sortKey {
                case .addedDate, .defaultSort:
                    return sortAscending == .secondItem
                case .title, .contributor:
                    return sortAscending == .firstItem
                }
            }()
            
            if sortKey == .defaultSort && sortAscending == .secondItem {
                sortKey = .addedDate
                sortAscending = .secondItem
            }
            
            switch sortKey {
            case .addedDate, .defaultSort:
                sortDescriptors = [NSSortDescriptor(keyPath: \BookInfo.addedDate, ascending: ascending)]
            case .title:
                sortDescriptors = [NSSortDescriptor(keyPath: \BookInfo.titleCollation, ascending: ascending)]
            case .contributor:
                sortDescriptors = [NSSortDescriptor(keyPath: \BookInfo.contributorCollations, ascending: ascending)]
            }
        }
    }
    
    @Published var sortKey: SortKey = .defaultSort {
        didSet {
            sortAscending = .firstItem
            switch sortKey {
            case .addedDate, .defaultSort:
                sortDescriptors = [NSSortDescriptor(keyPath: \BookInfo.addedDate, ascending: false)]
                ascendingFirstItemTitle = "新しい順"
                ascendingSecondItemTitle = "古い順"
            case .title:
                sortDescriptors = [NSSortDescriptor(keyPath: \BookInfo.titleCollation, ascending: true)]
                ascendingFirstItemTitle = "昇順"
                ascendingSecondItemTitle = "降順"
            case .contributor:
                sortDescriptors = [NSSortDescriptor(keyPath: \BookInfo.contributorCollations, ascending: true)]
                ascendingFirstItemTitle = "昇順"
                ascendingSecondItemTitle = "降順"
            }
        }
    }
    
    @Published var ascendingFirstItemTitle = "新しい順"
    @Published var ascendingSecondItemTitle = "古い順"
    @Published var sortDescriptors:[NSSortDescriptor] = [NSSortDescriptor(keyPath: \BookInfo.addedDate, ascending: false)]
    
}
