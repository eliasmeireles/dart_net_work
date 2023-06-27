clean:
	flutter clean

libs-update:
	flutter pub upgrade --major-versions

build-run:
	flutter clean
	flutter pub get
	flutter packages run build_runner build --delete-conflicting-outputs