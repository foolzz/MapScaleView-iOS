# MapScaleView-iOS

A map scale bar view for iOS — mirrors the Android [pengrad/mapscaleview](https://github.com/pengrad/mapscaleview) library.

Works with any map SDK (Google Maps, MapKit, Mapbox, etc.) that exposes zoom level and latitude from camera callbacks.

## Features

- Metric (m / km) and/or imperial (ft / mi) units
- Outline rendering for visibility on any map background
- Configurable color, text size, stroke width, and max width
- UIKit (`MapScaleView: UIView`) and SwiftUI (`MapScaleViewRepresentable`) interfaces
- Same API surface as the Android library for cross-platform consistency

## Installation

### Swift Package Manager

```swift
// Package.swift
.package(url: "https://github.com/yzhao-ca/MapScaleView-iOS.git", from: "1.0.0")
```

Or in Xcode: **File > Add Package Dependencies** and enter the repo URL.

### CocoaPods

```ruby
pod 'MapScaleView', '~> 1.0'
```

## Usage

### UIKit

```swift
import MapScaleView

let scaleView = MapScaleView()
scaleView.metersAndMiles()   // or .metersOnly() / .milesOnly()
view.addSubview(scaleView)

// In your map camera-change callback:
scaleView.update(zoom: position.zoom, latitude: position.target.latitude)
```

Hide at low zoom levels to match the Android app behavior:

```swift
scaleView.isHidden = zoom <= 4
```

### SwiftUI

```swift
import MapScaleView

struct RadarView: View {
    @State private var zoom: Float = 7
    @State private var latitude: Double = 45.0

    var body: some View {
        ZStack(alignment: .topLeading) {
            GoogleMapsViewRepresentable(zoom: $zoom, latitude: $latitude)
            if zoom > 4 {
                MapScaleViewRepresentable(zoom: zoom, latitude: latitude)
                    .fixedSize()
                    .padding(8)
            }
        }
    }
}
```

### Configuration

```swift
let scaleView = MapScaleView()
scaleView.setColor(.black)
scaleView.setOutlineColor(.white)
scaleView.setTextSize(12)
scaleView.setStrokeWidth(1.5)
scaleView.setOutlineEnabled(true)
scaleView.setMaxWidth(175)
```

## Scale Calculation

Resolution is computed using the standard Google Maps / OSM tile formula:

```
resolution (m/pt) = (40_075_016 m / 256) x cos(latitude) / 2^zoom
```

The scale bar snaps to the largest human-friendly distance that fits within `maxWidth`:

- Metric: 1, 2, 5 ... 500 m, then 1, 2, 5 ... 1 000 km
- Imperial: 1, 2, 5 ... 2 000 ft, then 1, 2, 5 ... 1 000 mi

## Requirements

- iOS 15+
- Swift 5.9+

## License

MIT
