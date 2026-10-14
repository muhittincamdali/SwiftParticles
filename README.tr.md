<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftUI-Animation-Masterclass/main/.github/brand/banner-tr-light.svg" alt="Animation Masterclass: iOS ve macOS için SwiftUI'da fizik tabanlı hareket, parçacıklar, değişim efektleri ve geçişler."></picture></p>

<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a></p>

# SwiftParticles taşındı

**Bu proje artık [SwiftUI-Animation-Masterclass](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass) içinde yaşıyor.**
Bu depo arşivlendi ve bir daha değişmeyecek. Burada yayımlanan son sürüm
[v1.0.0](https://github.com/muhittincamdali/SwiftParticles/releases/tag/v1.0.0).

## Kod nereye gitti

SwiftUI-Animation-Masterclass 2.0.0, bu deponun işe yarayan kısımlarını
[Particles](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/tree/main/Sources/SwiftUIAnimationMasterclass/Particles)
modülü olarak yeniden yazdı; parçacıklar tek bir SwiftUI `Canvas` içinde çizilir ve testlerle
korunur.

| Burada                | SwiftUI-Animation-Masterclass içinde                                                                                                                                                                                                    |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Emitter'lar           | [`ParticleEmitter`](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Sources/SwiftUIAnimationMasterclass/Particles/ParticleEmitter.swift)                                                                     |
| Kuvvetler             | [`ParticleForce`](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Sources/SwiftUIAnimationMasterclass/Particles/ParticleForce.swift): yerçekimi, rüzgâr, türbülans, çekim noktası ve girdap                  |
| Hazır ayarlar         | [`ParticlePresets`](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Sources/SwiftUIAnimationMasterclass/Particles/ParticlePresets.swift): confetti, fireworks, snow, rain, sparkles, bubbles, hearts, embers |
| SwiftUI view modifier | [`ParticleView`](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/Sources/SwiftUIAnimationMasterclass/Particles/ParticleView.swift), `.particleEffect(_:isActive:)` ve `.particleBurst(_:trigger:)` ile       |

Her şey taşınmadı. Pakette burada listelenen 25 değil, 8 hazır ayar var. Metal renderer, akışkan
dinamiği iskeleti, 3D parçacıklar, visionOS entegrasyonu ve `Enterprise` yardımcıları
(`CircuitBreaker`, `RetryPolicy`, `EventBus`) taşınmadı. Tam kapsam için
[2.0.0 değişiklik günlüğüne](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass/blob/main/CHANGELOG.md)
bakın.

## Yeni paketi kurun

```swift
.package(url: "https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass.git", from: "2.0.0")
```

Ardından `.product(name: "SwiftUIAnimationMasterclass", package: "SwiftUI-Animation-Masterclass")`
satırını target'ınıza ekleyin. iOS 17 veya macOS 14 ve Swift 6.2 gerekir. Tüm dokümantasyon:
[SwiftUI-Animation-Masterclass README](https://github.com/muhittincamdali/SwiftUI-Animation-Masterclass#readme).

## Lisans

MIT, bkz. [LICENSE](LICENSE).
