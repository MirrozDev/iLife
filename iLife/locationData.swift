//
//  locationData.swift
//  iLife
//
//  Created by Mirosław Witkowski.
//  Copyright © 2020 Mirosław Witkowski. All rights reserved.
//

import Foundation

// MARK: - LocationData struct
struct LocationData: Codable {
    let placeID: Int?
    let licence, osmType: String?
    let osmID: Int?
    let lat, lon, displayName: String?
    let address: Address
    let boundingbox: [String?]

    enum CodingKeys: String, CodingKey {
        case placeID = "place_id"
        case licence
        case osmType = "osm_type"
        case osmID = "osm_id"
        case lat, lon
        case displayName = "display_name"
        case address, boundingbox
    }
}

// MARK: - Address struct
struct Address: Codable {
    let city, municipality, county, state: String?
    let postcode, country, countryCode: String?

    enum CodingKeys: String, CodingKey {
        case city, municipality, county, state, postcode, country
        case countryCode = "country_code"
    }
}
