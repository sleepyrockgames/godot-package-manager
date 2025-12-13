# Godot Package Manager

> [!Warning]
This is currently a WIP project, and is not ready for production usage. Please use at your own risk!

## Overview
The Godot Package Manager is a simple plugin that allows users to create and import/export custom 'packages' to a local directory on their system. This enables the reuse of modular systems and asset packs between projects without the need to manually copy files into the project.

> How is this different from the Asset Manager?

The main difference is the source of the packages being imported. While the built-in asset manager allows pulling in assets from a remote source (e.g. the Godot asset repository), this package manager pulls from a separate 'shared' location on your local system. This allows the creation and usage of systems that may be under a restrictive license or otherwise are not able to be shared publicly. 
