# Xcode 8.3 on El Capitan

This guide provides a pretty nasty and a bit complicated way how to launch and use Xcode 8.3 on OS X El Capitan.

Please note there's no guarantee given it's going to work for you as flawlessly as for me and you won't end having your system full of dinosaurs and similar 'flip. :)

1. Navigate to `Xcode.app/Contents/MacOS`
2. Make a backup of `Xcode` binary (not necessary, but recommended)
3. Unsign Xcode using `MakeXcodeGr8Again` tool linked in the submodule
  - when opened, tick to overwrite Xcode, then drag the `Xcode` app into the window
4. Compile the `SideLoader` target
5. Copy `libSideLoader.dylib` to `Xcode.app/Contents/MacOS`
6. Compile `optool` target from the submodule
7. Copy to `optool` binary to `Xcode.app/Contents/MacOS`
8. Run command `(sudo) ./optool install -c load -p @executable_path/libSideLoader.dylib -t Xcode`
9. Check command success by listing `otool -L Xcode` which should list the inserted LOAD command on the last line
  - be aware, `otool` != `optool` :)
10. Re-sign the `Xcode` binary using [the manual on XVim repository](https://github.com/XVimProject/XVim/blob/master/INSTALL_Xcode8.md)
  - `(sudo) codesign --no-strict --force -s XcodeSigner Xcode`
  - Replace `XcodeSigner` with possible cert name of your choice
  - patiently wait a while…
11. Update the following property lists to allow launching on 10.11 by changing `LSMinimumSystemVersion` property to `10.11`:
  - `Xcode.app/Contents/Info.plist`
  - `Xcode.app/Contents/Applications/FileMerge.app/Contents/Info.plist`
  - `Xcode.app/Contents/Developer/Applications/Simulator.app/Contents/Info.plist`
  - `Xcode.app/Contents/Developer/Applications/Simulator (Watch).app/Contents/Info.plist`
12. Update `Xcode.app/Contents/Developer/usr/bin/copypng` to unblock compilation errors while copying over PNG images:
  - comment out lines 76–83 (add `#` at the beginning of the lines)
  - comment out line 85 (add `#` at the beginning of the line)
  - PNG images in your project won't be compressed even if set – use another tools like `ImageOptim` to make them smaller

You may need to restart your computer so the system forgots the minimum version settings of the apps modified.

Renaming of app works as well. Instantly for `Xcode` app. If `Simulator` app won't start after changing the minimum OS version value, rename it to `Simulator_.app` and create a symlink using `ln -s Simulator_.app Simulator.app`.
