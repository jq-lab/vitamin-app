import SwiftUI

enum VitoraTheme {
    enum ColorToken {
        static let canvas = Color(red: 250 / 255, green: 250 / 255, blue: 250 / 255)
        static let paper = Color.white
        static let paperWarmBase = Color(red: 248 / 255, green: 246 / 255, blue: 244 / 255)
        static let paperWarmLift = Color(red: 253 / 255, green: 251 / 255, blue: 248 / 255)
        static let paperWarmPeachMist = Color(red: 255 / 255, green: 224 / 255, blue: 230 / 255)
        static let paperWarmCyanMist = Color(red: 224 / 255, green: 244 / 255, blue: 248 / 255)
        static let surfacePearlMain = Color(red: 255 / 255, green: 254 / 255, blue: 250 / 255)
        static let surfacePearlInset = Color(red: 244 / 255, green: 242 / 255, blue: 239 / 255)
        static let paperLiftShadow = Color(red: 116 / 255, green: 112 / 255, blue: 106 / 255)
        static let auraCanvas = Color(red: 243 / 255, green: 249 / 255, blue: 255 / 255)
        static let auraBlue = Color(red: 72 / 255, green: 151 / 255, blue: 246 / 255)
        static let auraCyan = Color(red: 100 / 255, green: 218 / 255, blue: 255 / 255)
        static let auraLavender = Color(red: 151 / 255, green: 135 / 255, blue: 255 / 255)
        static let lutealGold = Color(red: 242 / 255, green: 184 / 255, blue: 78 / 255)

        // Amber brand palette (MoonPerson spec §2)
        static let amberBase = Color(red: 250 / 255, green: 238 / 255, blue: 218 / 255)    // #FAEEDA
        static let amberActive = Color(red: 250 / 255, green: 199 / 255, blue: 117 / 255)   // #FAC775
        static let amberMain = Color(red: 239 / 255, green: 159 / 255, blue: 39 / 255)      // #EF9F27
        static let amberDeep = Color(red: 186 / 255, green: 117 / 255, blue: 23 / 255)      // #BA7517
        static let amberDark = Color(red: 133 / 255, green: 79 / 255, blue: 11 / 255)       // #854F0B

        static let softSurface = Color(red: 245 / 255, green: 245 / 255, blue: 247 / 255)
        static let blueSoftSurface = Color(red: 232 / 255, green: 244 / 255, blue: 252 / 255)
        static let cardGlass = Color.white.opacity(0.72)
        static let shell = Color(red: 26 / 255, green: 26 / 255, blue: 26 / 255)
        static let primaryText = Color(red: 26 / 255, green: 26 / 255, blue: 26 / 255)
        static let strongText = Color(red: 26 / 255, green: 31 / 255, blue: 46 / 255)
        static let secondaryText = Color(red: 134 / 255, green: 134 / 255, blue: 139 / 255)
        static let tertiaryText = Color(red: 138 / 255, green: 138 / 255, blue: 153 / 255)
        static let mutedText = Color(red: 156 / 255, green: 163 / 255, blue: 175 / 255)
        static let actionPrimary = Color(red: 90 / 255, green: 200 / 255, blue: 250 / 255)
        static let actionPrimaryDeep = Color(red: 79 / 255, green: 146 / 255, blue: 215 / 255)
        static let actionPrimarySoft = Color(red: 217 / 255, green: 235 / 255, blue: 255 / 255)
        static let success = Color(red: 91 / 255, green: 168 / 255, blue: 85 / 255)
        static let attention = Color(red: 239 / 255, green: 68 / 255, blue: 68 / 255)
        static let warm = Color(red: 240 / 255, green: 139 / 255, blue: 82 / 255)
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let screenMargin: CGFloat = 16
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let card: CGFloat = 20
        static let sheet: CGFloat = 28
        static let pill: CGFloat = 999
    }

    enum Size {
        static let touchTargetMin: CGFloat = 44
        static let inputDockHeight: CGFloat = 44
        static let iconButtonMedium: CGFloat = 38
        static let tabBarHeight: CGFloat = 74
        static let globalVitoraDockHeight: CGFloat = 156
        static let contentWidth: CGFloat = 345
    }
}
