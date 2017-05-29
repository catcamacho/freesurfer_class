# More settings/details can be found at:
# https://surfer.nmr.mgh.harvard.edu/fswiki/TkMeditGuide/TkMeditReference/TkMeditScripting

# SetVolumeMinMax volume(0=main 1=aux) min max <--defines value for black and white
SetVolumeMinMax 0 0 255
SetVolumeMinMax 1 0 255

#SetVolumeBrightnessContrast (0=main 1=aux) brightness (0-1) contrast (0-30)
SetVolumeBrightnessContrast 0 .22 15

# The active tool(0=Navigate 1=Select Voxels 2=Edit Voxels 3=Edit Segmentation 4=Edit Control Points)
SetTool 2

# Flags correspond to different files. See full list at above address.
SetDisplayFlag 5 0

# 0=main volume; 1=aux volume; 2=both main and aux
SetBrushTarget 0

# radius shape(0=circle 1=square) 3D(0=2D editing 1=3D editing)
SetBrushShape 7 0 0
UpdateBrushInfo 0 0 255 255 1 1
SetEditBrushConfiguration

# floating point r g b values.
SetCursorColor .7 0 1

# Starting orientation (0=coronal 1=horizontal 2=sagittal)
SetOrientation 2

# Starting slice number
SetSlice 100

# Opens the brush info dialogue box on start up.
DoBrushInfoDlog


