
## DEPS
### Mockingbird https://mockingbirdswift.com/spm-project-quickstart

Mocks generating
```
DERIVED_DATA="$(xcodebuild -showBuildSettings | sed -n 's|.*BUILD_ROOT = \(.*\)/Build/.*|\1|p')"

"${DERIVED_DATA}/SourcePackages/checkouts/mockingbird/mockingbird" generate \
    --testbundle letme.remindTest \
    --targets letme.remind \
    --only-protocols \
    --output-dir letme.remindTests/mocks
```

Add letme.remindTests/mocks/letme_remindMocks.generated.swift to letme.remindTest compile source

### Swinject https://github.com/Swinject/Swinject
