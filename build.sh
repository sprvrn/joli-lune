#!/bin/bash

# compiling moonscript and copying the game file in out/
moonc -t out .
rsync -r --copy-links --exclude="*.moon" --exclude="*.ase" --exclude="*.aseprite" main.lua conf.lua src libs assets licenses out/

# get the game project infos
INFOS=$(lua getProjectInfo.lua)
IFS='/'
read -ra infotable <<< "$INFOS"
PRJNAME=${infotable[0]}
PRJDESCR=${infotable[1]}
PRJAUTHORS=${infotable[2]}
PRJVERSION=${infotable[3]}

LVFILE="$PRJNAME-v$PRJVERSION"
EXEFILE="$PRJNAME.exe"
APPIMGFILE="$LVFILE-x86_64.AppImage"
WINFILE="$LVFILE-win.zip"
OSXFILE="$LVFILE-osx.zip"

# make the .love file
cd out
zip -9 -r ../build/$LVFILE.love main.lua conf.lua src libs assets licenses

# window: append .love to the exe
cd ..
cat build/win/love.exe build/$LVFILE.love > build/win/$EXEFILE
cd build/win
zip -r "../$WINFILE" $EXEFILE SDL2.dll OpenAL32.dll license.txt love.dll lua51.dll mpg123.dll msvcp120.dll msvcr120.dll
cd ..

# linux : build the appimage
cd linux
./love-11.4-x86_64.AppImage --appimage-extract
cat squashfs-root/bin/love ../$LVFILE.love > squashfs-root/bin/$PRJNAME
chmod +x squashfs-root/bin/$PRJNAME
DESKTOPFILE="[Desktop Entry]\nName=$PRJNAME\nComment=$PRJDESCR by $PRJAUTHORS\nMimeType=application/x-love-game;\nExec=$PRJNAME %f\nType=Application\nCategories=Game;\nTerminal=false\nIcon=love\nNoDisplay=true"
echo -e $DESKTOPFILE > squashfs-root/love.desktop
./appimagetool-x86_64.AppImage squashfs-root "../$APPIMGFILE"

#osx
cd ..
cp -r love.app osx
cd osx
mv love.app "$PRJNAME.app"
cp ../$LVFILE.love "$PRJNAME.app/Contents/Resources/"
cd "$PRJNAME.app/Contents/Resources/"
mv $LVFILE.love "$PRJNAME.love"
cd ..
cd ..
cd ..
PLIST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>BuildMachineOSBuild</key>
	<string>21D49</string>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundleDocumentTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeExtensions</key>
			<array>
				<string>love</string>
			</array>
			<key>CFBundleTypeIconFile</key>
			<string>GameIcon</string>
			<key>CFBundleTypeName</key>
			<string>LÖVE Project</string>
			<key>CFBundleTypeRole</key>
			<string>Viewer</string>
			<key>LSHandlerRank</key>
			<string>Owner</string>
			<key>LSItemContentTypes</key>
			<array>
				<string>org.love2d.love-game</string>
			</array>
			<key>LSTypeIsPackage</key>
			<integer>1</integer>
		</dict>
		<dict>
			<key>CFBundleTypeName</key>
			<string>Folder</string>
			<key>CFBundleTypeOSTypes</key>
			<array>
				<string>fold</string>
			</array>
			<key>CFBundleTypeRole</key>
			<string>Viewer</string>
			<key>LSHandlerRank</key>
			<string>None</string>
		</dict>
		<dict>
			<key>CFBundleTypeIconFile</key>
			<string>Document</string>
			<key>CFBundleTypeName</key>
			<string>Document</string>
			<key>CFBundleTypeOSTypes</key>
			<array>
				<string>****</string>
			</array>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
		</dict>
	</array>
	<key>CFBundleExecutable</key>
	<string>love</string>
	<key>CFBundleIconFile</key>
	<string>OS X AppIcon</string>
	<key>CFBundleIconName</key>
	<string>OS X AppIcon</string>
	<key>CFBundleIdentifier</key>
	<string>com.$PRJAUTHORS.$PRJNAME</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$PRJNAME</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>11.4a</string>
	<key>CFBundleSignature</key>
	<string>LoVe</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>MacOSX</string>
	</array>
	<key>DTCompiler</key>
	<string>com.apple.compilers.llvm.clang.1_0</string>
	<key>DTPlatformBuild</key>
	<string>13C100</string>
	<key>DTPlatformName</key>
	<string>macosx</string>
	<key>DTPlatformVersion</key>
	<string>12.1</string>
	<key>DTSDKBuild</key>
	<string>21C46</string>
	<key>DTSDKName</key>
	<string>macosx12.1</string>
	<key>DTXcode</key>
	<string>1321</string>
	<key>DTXcodeBuild</key>
	<string>13C100</string>
	<key>LSApplicationCategoryType</key>
	<string>public.app-category.games</string>
	<key>LSMinimumSystemVersion</key>
	<string>10.7</string>
	<key>NSHighResolutionCapable</key>
	<true/>
	<key>NSHumanReadableCopyright</key>
	<string>© 2006-2022 LÖVE Development Team</string>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
	<key>NSSupportsAutomaticGraphicsSwitching</key>
	<false/>
</dict>
</plist>"
cd "$PRJNAME.app"
echo -e $PLIST > Contents/Info.plist
cd ..
zip -y -r "../$OSXFILE" "$PRJNAME.app"
cd ..

#version and build's list
BUILDFILE="$PRJVERSION\nwindows:$WINFILE\nosx:$OSXFILE\nlinux:$APPIMGFILE\nsource:$LVFILE.love"
echo -e $BUILDFILE > buildinfo.txt