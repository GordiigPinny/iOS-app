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


// MARK: - PageDto protocol
protocol PageDto: Codable, Hashable {
    associatedtype Entity: ConvertableToDto
    
    func toEntities() -> [Entity]
    func toListDtos() -> [Entity.ListDto]
    static func fromEntities(_ entities: [Entity]) -> Self
    
}


// MARK: - ConvertableToDto protocol
protocol ConvertableToDto {
    associatedtype ListDto: Dto where ListDto.Entity == Self
    associatedtype DetailDto: Dto where DetailDto.Entity == Self
    associatedtype PgDto: PageDto where PgDto.Entity == Self
    
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
    func fromListDto(_ dto: ListDto) -> Self {
        return dto.toEntity()
    }
    
    func fromDetailDto(_ dto: DetailDto) -> Self {
        return dto.toEntity()
    }
    
    static func fromPageDto(_ dto: PgDto) -> [Self] {
        return dto.toEntities()
    }
}
