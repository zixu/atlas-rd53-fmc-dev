# atlas-rd53-fmc-dev

<!--- ########################################################################################### -->

# Before you clone the GIT repository

1) Create a github account:
> https://github.com/

2) On the Linux machine that you will clone the github from, generate a SSH key (if not already done)
> https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/

3) Add a new SSH key to your GitHub account
> https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

4) Setup for large filesystems on github

```
$ git lfs install
```

5) Verify that you have git version 2.13.0 (or later) installed 

```
$ git version
git version 2.13.0
```

6) Verify that you have git-lfs version 2.1.1 (or later) installed 

```
$ git-lfs version
git-lfs/2.1.1
```

<!--- ########################################################################################### -->

# Clone the GIT repository

```
$ git clone --recursive git@github.com:slaclab/atlas-rd53-fmc-dev
```

<!--- ########################################################################################### -->

# How to build the KC705 PCIe firmware

Note: For KC705, using the QSPI (not BPI) for booting from PROM.
      J3 needs to have the jumper installed 
      SW13 needs to be in the "00001" position to set FPGA.M[2:0] = "001"

1) Setup Xilinx licensing

> If you are on the SLAC network, here's how to setup the Xilinx licensing

```
$ source atlas-rd53-fmc-dev/firmware/setup_env_slac.sh
```

2) Go to the target directory and make the firmware:
```
$ cd atlas-rd53-fmc-dev/firmware/targets/AtlasRd53FmcXilinxKc705/
$ make
```

3) Optional: Review the results in GUI mode
```
$ make gui
```

<!--- ########################################################################################### -->

# How to build the KCU105 PCIe firmware

1) Setup Xilinx licensing

> If you are on the SLAC network, here's how to setup the Xilinx licensing

```
$ source atlas-rd53-fmc-dev/firmware/setup_env_slac.sh
```

2) Go to the target directory and make the firmware:
```
$ cd atlas-rd53-fmc-dev/firmware/targets/AtlasRd53FmcXilinxKcu105/
$ make
```

3) Optional: Review the results in GUI mode
```
$ make gui
```

<!--- ########################################################################################### -->

# How to build the ZCU102 RCE firmware

1) Setup Xilinx licensing

> If you are on the SLAC network, here's how to setup the Xilinx licensing

```
$ source atlas-rd53-fmc-dev/firmware/setup_env_slac.sh
```

2) Go to the target directory and make the firmware:
```
$ cd atlas-rd53-fmc-dev/firmware/targets/AtlasRd53FmcXilinxZcu102/
$ make
```

3) Optional: Review the results in GUI mode
```
$ make gui
```

<!--- ########################################################################################### -->

# How to load the PCIe driver

```
# Confirm that you have the board the computer with VID=1a4a ("SLAC") and PID=2030 ("AXI Stream DAQ")
$ lspci -nn | grep SLAC
04:00.0 Signal processing controller [1180]: SLAC National Accelerator Lab TID-AIR AXI Stream DAQ PCIe card [1a4a:2030]

# Clone the driver github repo:
$ git clone --recursive https://github.com/slaclab/aes-stream-drivers

# Go to the driver directory
$ cd aes-stream-drivers/data_dev/driver/

# Build the driver
$ make

# Load the driver
$ sudo /sbin/insmod ./datadev.ko cfgSize=0x50000 cfgRxCount=256 cfgTxCount=16

# Give appropriate group/permissions
$ sudo chmod 666 /dev/data_dev*

# Check for the loaded device
$ cat /proc/data_dev0
```

<!--- ########################################################################################### -->

# How to install the Rogue With Anaconda

> https://slaclab.github.io/rogue/installing/anaconda.html

<!--- ########################################################################################### -->

# How to reprogram the PCIe firmware via Rogue software

Note: For KC705, using the QSPI (not BPI) for booting from PROM.
      J3 needs to have the jumper installed 
      SW13 needs to be in the "00001" position to set FPGA.M[2:0] = "001"

1) Setup the rogue environment
```
# Go to software directory
$ cd atlas-rd53-fmc-dev/software

# Activate Rogue conda Environment 
$ source /path/to/my/anaconda3/etc/profile.d/conda.sh
$ conda activate rogue_env
```

2) Run the FEB firmware update script:
```
$ python3 scripts/updatePcieProm.py --path <PATH_TO_IMAGE_DIR>
```
where <PATH_TO_IMAGE_DIR> is path to image directory (example: ../firmware/targets/AtlasRd53FmcXilinxKc705/images/)

3) Reboot the computer
```
sudo reboot
```

<!--- ########################################################################################### -->


# How to run the Rogue PyQT GUI for the PCIe platforms

1) Setup the rogue environment
```
# Go to software directory
$ cd atlas-rd53-fmc-dev/software

# Activate Rogue conda Environment 
$ source /path/to/my/anaconda3/etc/profile.d/conda.sh
$ conda activate rogue_env
```

2) Launch the GUI:
```
$ python3 scripts/guiPcie.py
```

<!--- ########################################################################################### -->
