clean:
	flutter clean

libs-update:
	flutter pub upgrade --major-versions

apk:
	flutter clean
	flutter pub get
	flutter pub run i18n_json
	flutter pub run build_runner build --delete-conflicting-outputs
	flutter build apk --dart-define=targetBuild=dev --split-per-abi --target-platform android-arm,android-arm64,android-x64
	open build/app/outputs/flutter-apk/

apk-prod:
	flutter clean
	flutter pub get
	flutter pub run i18n_json
	flutter pub run build_runner build --delete-conflicting-outputs
	flutter build apk --dart-define=targetBuild=prod --split-per-abi --target-platform android-arm,android-arm64,android-x64
	open build/app/outputs/flutter-apk/

text:
	flutter pub run i18n_json

build-run:
	flutter pub get
	flutter pub run i18n_json
	flutter pub run build_runner build --delete-conflicting-outputs

build-watch-run:
	flutter pub get
	flutter pub run i18n_json
	flutter pub run build_runner watch --delete-conflicting-outputs --use-polling-watcher
