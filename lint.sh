set -e -x

echo Installing linter
pub global activate linter

echo Linting library
pub global run linter .
