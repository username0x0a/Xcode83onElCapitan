# Xcode 8.3+ on El Capitan

This guide provides a pretty nasty and a bit complicated way how to launch and use Xcode 8.3+ on OS X El Capitan.

Simply said this sideload patch implements SDK calls missing on El Capitan (namely newly added `Foundation` methods on `NSThread`, but there's possibly more) which is a pretty weak argument for dropping El Capitan support from Apple. However this is pretty “usual” in these days (sadly) if you take a look at the support for the other software like iLife/iWork apps etc. none of them working on older (yet stable, unlike Sierra!) OS versions which I consider a huge care loss – another one in a longer line of sad (especially for developers and power users) stories – Spotlight extensions cut, Xcode plugins cut, lack of support, very buggy Sierra release. Making the platforms more and more closed and moving those less profitable ones out of any attention is definitely a sad story.

Please note there's no guarantee given it's going to work for you as flawlessly as for me and you won't end having your system full of dinosaurs and similar 'flip. :)

## Benefits

1. Xcode _more or less_ working :)
2. Xcode working including the plugins (we're talking about you, [Alcatraz](http://alcatraz.io/)!)
3. Xcode working with Keychain Access

## Warning

It's not recommended to use such bumped version of Xcode neither to upload builds to the App Store nor to use it as your primary Xcode installation. I prefer patching the version downloaded from the Developer Downlaods as I don't have to deal with file privileges etc. and still use Xcode 8.2.1 supported on El Capitan.

## Set of tools mentioned

- [`MakeXcodeGr8Again`](https://github.com/fpg1503/MakeXcodeGr8Again)
- `otool` – included with `Command Line Tools`
- [`optool`](https://github.com/alexzielenski/optool)
- `codesign` – included with Xcode/`Command Line Tools`
- [`unsign`](https://github.com/steakknife/unsign)

## Steps to follow

1. Navigate to `Xcode.app/Contents/MacOS`
2. Make a backup of `Xcode` binary (not necessary, but recommended)
3. Unsign Xcode using `MakeXcodeGr8Again` tool linked in the submodule or using `unsign` tool
  - when opened, tick to overwrite Xcode, then drag the `Xcode` app into the window
4. Compile the `SideLoader` target
5. Copy `libSideLoader.dylib` to `Xcode.app/Contents/MacOS`
6. Compile `optool` target from the submodule
7. Copy to `optool` binary to `Xcode.app/Contents/MacOS`
8. Run command `(sudo) ./optool install -c load -p @executable_path/libSideLoader.dylib -t Xcode`
9. Check command success by listing `otool -L Xcode` which should list the inserted LOAD command on the last line
  - be aware, `otool` != `optool` :)
10. Re-sign the `Xcode` binary using the home-made certificate by following [the manual on XVim repository](https://github.com/XVimProject/XVim/blob/master/INSTALL_Xcode8.md)
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
  - PNG images in your project won't be compressed even if set so by your project file – use another tools like `ImageOptim` to make them compressed

You may need to restart your computer so the system forgots the minimum version settings of the apps modified.

Renaming of app bundle works as well. Instantly for `Xcode` app. If `Simulator` app won't start after changing the minimum OS version value, rename it to `Simulator_.app` and create a symlink using `ln -s Simulator_.app Simulator.app`.

## Bugs and other reports

Do not hesitate to fill an issue. :)
