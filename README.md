# needsly

Minimalistic daily needs tracker that allows to keep them in order.

It is simple:

- Add items by organizing them into lists
- Resolve items
- Observe stats
- Work on shared by network items in collaboration

## Prerequisites for development

[Flutter](https://docs.flutter.dev/get-started/install)

## Build

```
flutter pub get
flutter pub run build_runner build
```

## Run and connect to Android emulator

```
flutter emulators --launch Medium_Phone_API_36.0
flutter run --debug
```

## Run and connect to Chrome

```
flutter build web
flutter run -d chrome
```

## Build and deploy as Github pages

```
flutter build web --base-href="/<repo-name>/"
git checkout --orphan gh-pages
git rm -rf .
cp -r build/web/* .
git add .
git commit -m "Deploy web app"
git push origin gh-pages --force
```

App will be available at `https://<username>.github.io/<repo-name>/`
Make sure [github-pages](https://docs.github.com/en/pages/quickstart) is enabled in your github repository.
