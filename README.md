# lunge

*Software for quantitative lung image analysis*

## Requirements
- Matlab<sup>TM</sup> 7.9.0.529 (R2009b)
- Image Processing Toolbox
- Signal Processing Toolbox

## Usage
Download the program clicking in the "Download Zip" button. Unzip the folder
and then execute the following steps in Matlab<sup>TM</sup> Command Window:

```matlab
>> cd /path/to/program/code/
>> lunge
```

## How to contribute
Download or fork the current repository, use your favourite text editor
and apply the following code convetion:

### Code convetions
- [camelCase](https://en.wikipedia.org/wiki/CamelCase)
- space between operators
- comments when necessary
- docstring in all created funtion

```matlab
%Estimates lung total volume.
volumeLunge = numberOfVoxels * voxelVolume;
```
