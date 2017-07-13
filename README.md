# Robust Visual Tracking Via Hierarchical Convolutional Features

### Introduction

This is the research code for an extended version of the ICCV2015 paper: 

[Chao Ma](https://sites.google.com/site/chaoma99/), [Jia-Bin Huang](https://filebox.ece.vt.edu/~jbhuang/), [Xiaokang Yang](http://english.seiee.sjtu.edu.cn/english/detail/842_802.htm) and [Ming-Hsuan Yang](http://faculty.ucmerced.edu/mhyang/), "Hierarchical Convolutional Features for Visual Tracking", ICCV 2015. For the earlier version of reserch code, please visit our [Project page](https://github.com/jbhuang0604/CF2).

In this source code, we added the components for (i) scale estimation and (ii) target redetection from tracking failures caused by heavy occlusion or targets moving out of the view. We propose to use another correlation filter to maintain a long-term memory of target appearance as a classifier. By adjusting the parameters, we tailor the off-the-shelf EdgeBox toolbox to generate two types of region proposals: (i) proposals tightly around the estimated location as candidates for scale estimation; (ii) proposals sampled across the whole image as candidates for target re-detection. We apply the classifier to
these two types of proposals and respectively select the proposals with highest response scores for scale estimation and target re-detection.

The correlation filters with convolutional features is a state-of-the-art tracker that exploits rich feature hierarchy from deep convolutional neural networks for visual tracking. For more details, please visit our [Project page](https://sites.google.com/site/chaoma99/hcft-tracking).

<img src="https://drive.google.com/uc?id=0B8-i_hZvGyZNMzFBb2RMWjJ0Z2s&amp;export=download" width="720" />


### Citation

If you find the code and dataset useful in your research, please consider citing:

    @inproceedings{Ma-HCFTstar-2017,
        title={Robust Visual Tracking via Hierarchical Convolutional Features},
        Author = {Ma, Chao and Huang, Jia-Bin and Yang, Xiaokang and Yang, Ming-Hsuan},
        booktitle = {arXiv prePreprint},
        pages={},
        Year = {2017}
    }


    @inproceedings{Ma-ICCV-2015,
        title={Hierarchical Convolutional Features for Visual Tracking},
        Author = {Ma, Chao and Huang, Jia-Bin and Yang, Xiaokang and Yang, Ming-Hsuan},
        booktitle = {Proceedings of the IEEE International Conference on Computer Vision},
        pages={},
        Year = {2015}
    }

### Contents
|  Folder    | description |
| ---|---|

Feedbacks and comments are welcome! Feel free to contact us via [chaoma99@gmail.com](mailto:chaoma99@gmail.com) or [jbhuang1@illinois.edu](mailto:jbhuang1@illinois.edu).

Enjoy!


