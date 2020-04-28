//
//  Dto.swift
//  Pinny-iOS
//
//  Created by Dmitry Gorin on 26.04.2020.
//  Copyright © 2020 gordiig. All rights reserved.
//

import Foundation


// MARK: - Dto protocol
protocol Dto: Codable, Hashable {
    associatedtype Entity: ConvertableToDto
    
    func toEntity() -> Entity
    static func fromEntity(_ entity: Entity) -> Self
    
}


// MARK: - PageDto struct
struct PageDto<Entity: ConvertableToDto>: Codable {
    var next: String?
    var prevoius: String?
    var count: Int
    var results: [Entity.ListDto]
    
    func toEntities() -> [Entity] {
        let ans = results.map { $0.toEntity() }
        return ans
    }
    
    static func fromEntities(_ entities: [Entity]) -> Self {
        let results = entities.map { $0.toListDto() }
        let ans = PageDto(next: nil, prevoius: nil, count: results.count, results: results)
        return ans
    }
}


// MARK: - ConvertableToDto protocol
protocol ConvertableToDto: class {
    associatedtype ListDto: Dto where ListDto.Entity == Self
    associatedtype DetailDto: Dto where DetailDto.Entity == Self
    typealias PgDto = PageDto<Self>
    
    var isDetailed: Bool { get set }
    var detailedOnListDto: Bool { get }
    
    func toListDto() -> ListDto
    func toDetailDto() -> DetailDto
    func toPageDto() -> PgDto
    
    static func fromListDto(_ dto: ListDto) -> Self
    static func fromDetailDto(_ dto: DetailDto) -> Self
    static func fromPageDto(_ dto: PgDto) -> [Self]
    
}

// MARK: - ConvertableToDto ext
extension ConvertableToDto {
    // To dto
    func toListDto() -> ListDto {
        return ListDto.fromEntity(self)
    }
    
    func toDetailDto() -> DetailDto {
        return DetailDto.fromEntity(self)
    }
    
    func toPageDto() -> PgDto {
        return PgDto.fromEntities([self])
    }
    
    // From dto
    static func fromListDto(_ dto: ListDto) -> Self {
        let ans = dto.toEntity()
        ans.isDetailed = ans.detailedOnListDto
        return ans
    }
    
    static func fromDetailDto(_ dto: DetailDto) -> Self {
        let ans = dto.toEntity()
        ans.isDetailed = true
        return ans
    }
    
    static func fromPageDto(_ dto: PgDto) -> [Self] {
        let ans = dto.toEntities()
        for e in ans {
            e.isDetailed = e.detailedOnListDto
        }
        return ans
    }
    
}
