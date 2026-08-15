/// Public surface of the set-wallpaper feature.
///
/// Other features (Wallpaper Detail today, Collection Detail in MO-006) open
/// the flow through this barrel rather than reaching into
/// `presentation/widgets/…`. Principle XI forbids importing another feature's
/// *internal* files; a deliberate entry point is what keeps that boundary real.
library;

export 'presentation/widgets/set_wallpaper_sheet.dart'
    show showSetWallpaperSheet;
