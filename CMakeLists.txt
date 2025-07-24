cmake_minimum_required(VERSION 3.16)

project(gamemodechecker)

# Find required components
find_package(ECM 5.90.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

# Install the plasmoid
plasma_install_package(. org.kde.gamemodechecker)

# Install translations
ki18n_install(po)
