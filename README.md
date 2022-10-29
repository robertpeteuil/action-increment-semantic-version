# Increment Semantic Version

This is a GitHub action to bump a given semantic version, depending on a given version fragment.

## Inputs

### `current-version`

**Required** The current semantic version you want to increment. (e.g. 3.12.5)

### `version-fragment`

**Required** The versions fragment you want to increment.

Possible options:

- `major` - increment SemVer major release; A in A.x.x
- `feature` or `minor` - increment SemVer minor release; B in x.B.x
- `bug` or `patch` - increment SemVer patch release; C in x.x.C
- `alpha` - increment count for existing alpha release, or convert standard release to alpha
  - cannot increment `beta` or `rc` pre-releases to `alpha`
- `beta` - increment count for existing beta release, or convert alpha or standard release to beta
  - cannot increment `rc` pre-releases to `alpha`
- `rc` - increment count for existing rc release, or convert alpha, beta or standard release to rc

## Outputs

### `next-version`

The incremented version.

## Example usage

``` yml
    - name: Bump release version
      id: bump_version
      uses: robertpeteuil/increment-version-action@master
      with:
        current-version: '2.11.7'
        version-fragment: 'minor'
    - name: Do something with your bumped release version
      run: echo ${{ steps.bump_version.outputs.next-version }}
      # will print 2.12.0
```

## Creating pre-release versions

- create a pre-release version from a standard release by calling action twice
  - first to set major/minor/patch values
  - second to set pre-release

## input / output Examples

> to update

| version-fragment | current-version |   | output        |
| ---------------- | --------------- | - | ------------- |
| major            | 2.11.7          |   | 3.0.0         |
| major            | 2.11.7-alpha3   |   | 3.0.0         |
| feature (minor)  | 2.11.7          |   | 2.12.0        |
| feature (minor)  | 2.11.7-alpha3   |   | 2.12.0        |
| bug (patch)      | 2.11.7          |   | 2.11.8        |
| bug (patch)      | 2.11.7-alpha3   |   | 2.11.8        |
| alpha            | 2.11.7          |   | 2.11.7-alpha1 |
| alpha            | 2.11.7-alpha3   |   | 2.11.7-alpha4 |
| beta             | 2.11.7          |   | 2.11.7-beta1  |
| beta             | 2.11.7-alpha3   |   | 2.11.7-beta1  |
| rc               | 2.11.7          |   | 2.11.7-rc1    |
| rc               | 2.11.7-alpha3   |   | 2.11.7-rc1    |

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE)
