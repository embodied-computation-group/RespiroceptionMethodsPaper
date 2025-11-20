# The Respiratory Resistance Sensitivity Task: An Automated Method for Quantifying Respiratory Interoception and Metacognition

This repository contains data, code and supporting documents for the manuscript:

https://www.biorxiv.org/content/10.1101/2021.10.14.464418v1

Please cite as:

>Nikolova, N., Harrison, O. K., Toohey, S., Braendholt, M., Legrand, N., Correa, C. C., Vejlo, M., Fardo, F., & Allen, M. (2021). The Respiratory Resistance Sensitivity Task: An Automated Method for Quantifying Respiratory Interoception and Metacognition. BioRxiv, 2021.10.14.464418. https://doi.org/10.1101/2021.10.14.464418

# Abstract
>The ability to sense, monitor, and control respiration - e.g., respiratory interoception (henceforth, respiroception) is a core homeostatic ability. Beyond the regulation of gas exchange, enhanced awareness of respiratory sensations is directly related to psychiatric symptoms such as panic and anxiety. Indeed, chronic breathlessness (dyspnea) is associated with a fourfold increase in the risk of developing depression and anxiety, and the regulation of the breath is a key aspect of many mindfulness-based approaches to the treatment of mental illness. Physiologically speaking, the ability to accurately monitor respiratory sensations is important for optimizing cardiorespiratory function during athletic exertion, and can be a key indicator of illness. Given the important role of respiroception in mental and physical health, it is unsurprising that there is increased interest in the quantification of respiratory psychophysiology across different perceptual and metacognitive levels of the psychological hierarchy. Compared to other more popular modalities of interoception, such as in the cardiac domain, there are relatively few methods available for measuring aspects of respiroception. Existing inspiratory loading tasks are difficult to administer and frequently require expensive medical equipment, or offer poor granularity in their quantification of respiratory-related perceptual ability. To facilitate the study of respiroception, we here present a new, fully automated and computer-controlled apparatus and psychophysiological method, which can flexibly and easily measure respiratory-related interoceptive sensitivity, bias and metacognition, in as little as 30 minutes of testing, using easy to make 3D printable parts. 

# Data
All anonymized trial and group-level data associated with this manuscript can be found here:

https://github.com/embodied-computation-group/RespiroceptionMethodsPaper/tree/main/data

# Code

This repository contains all needed code to run the RRST itself, as well as associated data preprocessing and analysis scripts.

# Figures

## Figure 1 - The Respiratory Resistance Sensitivity Task - Apparatus and Design
<img src="/figs/figure_1.png" align="center" alt="f1" HSPACE=30>

>Figure 1: The Respiratory Resistance Discrimination Task. A) Trial schematic depicting the 2-interval forced choice (2IFC) design of the task. On each trial participants view a circular cue instructing them to prepare to inhale. The circle then blinks and begins expanding, with the participant instructed to sharply inhale with the expansion of the circle. The participant then exhales, and a second similarly guided breath is conducted. This procedure of pacing the participant’s breathing via visual cues is a novel feature of the RRST, and is intended to reduce intra- and inter-subject variance in respiratory effort. Following the two breaths, the participant indicates by keyboard press whether the first or second breath was more difficult. B) Sample single subject data, illustrating the psychophysical procedure. On each trial, one of two breaths is randomly signal minus (s-), such that the compression wedge is at resting baseline (0% obstruction) with no added resistance, and the other signal plus (s+) with some level of compression determined by the staircase procedure. The procedure rapidly hones in on a threshold estimate using a Bayesian procedure (psi); in this example the participant threshold of approximately 80% obstruction is found within just 20 trials. C) Schematic illustrating the design of the automated resistive load apparatus (see Supplementary Material 1 - Detailed schematic for details). 

## Figure 2 - Respiratory Psychophysical Functions
<img src="/figs/figure_2.png" align="center" alt="f2" height="600" HSPACE=30>

>Figure 2: Psychometric task results. A) Plot depicting trial-by-trial Psi threshold estimates for all participants. Light gray lines depict individual stimulus traces indicating the % of tube obstruction on the stimulus breath for each trial, the thick green line represents grand mean stimulus on each trial +- SEM. In general, threshold estimates stabilize around trials 20-40 for all participants. B) PMF fits for all subjects. The green lines depict individuals’ PMF fits, and grey points show stimulus levels presented, where the dot size indicates the number of times presented. C) Grand mean psychometric fit (green) overlaid on individual PMF fits (grey), demonstrating that average respiratory thresholds are around 66% airway obstruction, with substantive inter-individual variance around this value. D) Raincloud plots (Allen, Poggiali, et al., 2019) depicting individual threshold (green) and slope (orange) estimates for all subjects. 

## Figure 3 - Task Accuracy, Reaction Time, and Accuracy
<img src="/figs/figure_3.png" align="center" alt="f3" height="600" HSPACE=30>

>Figure 3: Type 1 performance on Psi & QUEST methods. Raincloud plots of reaction times (RT, left panel) and stimulus level (right panel) by accuracy (correct vs. incorrect) for the Psi (upper panel) and QUEST (lower panel) staircase methods. A) & C) Median RTs presented for each subject, for correct (green) and incorrect (orange) trials showing that RTs on correct trials are lower than on incorrect trials. B) & D) Average stimulus levels presented for each subject, for correct and incorrect trials, showing that stimuli were higher (i.e., easier) on correct trials.  These results indicate good overall convergence of estimated psychometric thresholds. 

## Figure 4 - Staircase Convergence and Reliability
<img src="/figs/figure_4.png" align="center" alt="f4" height="600" HSPACE=30>

>Figure 4: Staircase convergence and Task Reliability.  A) Standard errors of the threshold estimate by trial number obtained with Psi indicate that reliable threshold estimates are derived within 20-50 trials. B) Standard errors of the slope estimate by trial number show that slope uncertainty drops linearly as a function of trials, indicating that slope estimates may benefit from higher trial numbers and/or hierarchical modelling. C) The difference to the final threshold estimates by trial number obtained with QUEST indicates that threshold estimates also converge within 20-50 trials. D) Correlation plot across the two (counter-balanced) QUEST and Psi threshold estimates indicates a high within-subject reliability of respiroceptive thresholds, regardless of estimation technique.

## Figure 5 - Respiratory Metacognition
<img src="/figs/figure_5.png" align="center" alt="f5" height="600" HSPACE=30>

>Figure 5: Type 2 performance.  A)  Raincloud plot showing stimulus level by confidence rating, showing higher confidence ratings for stimuli with greater resistance. B)  Histogram of binned confidence ratings for correct (green) and incorrect (orange) trials. Generally, participants showed high metacognitive sensitivity, as seen in the dissociation between the correct and incorrect trial ratings. C) Type 2 ROC curve, averaged over participants, showing good respiroceptive type 2 performance. D) Type 1 (accuracy, green) and type 2 (aROC, orange) performance, sorted by each participant’s aROC. Participants show substantial variations in metacognition while type 1 accuracy is held relatively constant by the Psi staircase procedure. 

## Figure 6 - Stimulus Averiseness and other Symptoms
<img src="/figs/figure_6.png" align="center" alt="f6" height="400" HSPACE=30>

>Figure 6: Task tolerance & subjective ratings. A) Plot depicting aversiveness ratings across all 10 blocks (timepoints) of testing. Mean aversiveness ratings after each block are shown in green, and the shaded gray area represents standard error of the mean (SEM). Each block comprised 20 trials, for a total testing time of approximately 45 minutes. Participants on average reported roughly 20% stimulus aversiveness (out of 100 total), which remains stable throughout the testing period. This indicates that the stimuli were mildly unpleasant and that extended testing time did not increase task adversity within these limits. B) Plot depicting mean dizziness, breathlessness and asthma symptoms across participants. Bar height represents mean ratings, error bars denote SEM, and gray circles show individual participants’ ratings. In general, participants showed low levels of these adverse effects following 1 full hour of testing, indicating good tolerability of the task. 



# Device specifications and parts

## May 2022
We have made an update to the RRST appratus harware and software. 
An updated parts list for the device is available at: https://docs.google.com/spreadsheets/d/1Xm-xjyxZgqfn2RlGidUxHrNGNTMF7fd8MpfaUctbE9U/edit?usp=sharing
New versions of the 3d printing files, PCB design, and code for running the task are available in ./task/RRS_3-0
Instructions for setting up and running the RRST can be found here: https://docs.google.com/document/d/1KxjABdMcecnZfaXCnsQhJQzVfaNqk7DXVoDFSJKMT78/edit?usp=sharing
(Note that these were created for data collection during the COVID pandemic, and therefore include more sanitisation procedures than would usually be necessary.)

## November 2025 Update
Fixed an issue where the expanding ring stimulus was not scaling correctly on high-resolution displays. The stimulus is now generated programmatically (`showExpandingRingGenerated.m`) instead of using a pre-rendered movie file, ensuring consistent sizing and timing across different screen resolutions. This change has been applied to both the main task and the tutorial. The original movie-based method (`showExpandingRing.m`) is preserved in the codebase but commented out in the calling scripts.

