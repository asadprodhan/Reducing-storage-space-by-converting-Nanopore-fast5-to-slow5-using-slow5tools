# **Reducing storage space by converting Nanopore fast5 to slow5 using slow5tools** <br />


Nanopore fast5 files contain raw signal data. Generally, these signal data are converted to base sequences (fastq) though basecalling before downstream analysis. Although, some bioinformatics algorithms directly access these raw signal data (fast5 file) for a variety of reasons such as improving sequence accuracy (Loman et al., 2015). However, storing and managing the fast5 files require disk space of tens of hundreds of gigabytes. Furthermore, parallel access to the fast5 files by multiple CPU threads, an efficient approach in modern genomics, is restricted. This is because fast5 files are based on HDF5 file format; and the input/output access request by the multiple CPU threads is serialised by HDF5 library, a library that reads and writes data in HDF5 file. 


However, the slow5tools (Gamaarachchi et al., 2022) can convert the Nanopore fast5 files to slow5/blow5 files that require less storage space compared to that for fast5. In addition, blow5 files allow for parallel access by the multiple CPU threads. The slow5tools software is well documented (Gamaarachchi, 2022) to follow on.


Here, I compile the steps that I followed to set up the slow5tools on Linux (Ubuntu 18.04) computer. I also present a ‘question and answer’ section that describes a warning message, how storage space is saved, and whether guppy basecalling can be applied again after the conversion.



## **How to set up?**


### **Install slow5tools using one of the following options**

```
conda install slow5tools -c bioconda slow5tools
```
```
conda install slow5tools -c conda-forge slow5tools
```

Or, using wget as follows:

```
wget “https://github.com/hasindu2008/slow5tools/releases/download/v0.3.0/slow5tools-v0.3.0-x86_64-linux-binaries.tar.gz”
```

Then, extract the tar file
```
tar xvf slow5tools-v0.3.0-x86_64-linux-binaries.tar.gz
```

slow5tools-v0.3.0 is the directory that contains the slow5tools command.



### **Add the ‘slow5tools’ command path to the bashrc profile**


- get the path of the ‘slow5tools-v0.3.0’ directory by running ‘pwd’
- export PATH=$PATH:/path_of_the_slow5tools-v0.3.0_directory
- now, the command ‘slow5tools’ can be run outside the ‘slow5tools-v0.3.0’ directory
- this path can be permanently add to the bashrc profile. Open the bashrc profile using a text editor like 
```
nano ~/.bashrc
```
- then add “export PATH=$PATH:/path_of_the_slow5tools-v0.3.0_directory”
- to confirm, open a terminal and run ‘slow5tools’. It should show the command usage information instead of the 'command not found' message




Nanopore fast5 is based on hdf5 (hierarchical data format) file and uses ‘VBZ Compression’ to compress the data. Therefore, the fast5 needs to be uncompressed for converting them to slow5 or blow5 files. The ‘ont-vbz-hdf-plugin’ can uncompress the nanopore fast5 files.  



### **Install HDF5 plugin**


**Use the helper script from slow5tools:**


- cd scripts directory that is located inside the ‘slow5tools-v0.3.0’ directory 
- ./install-vbz.sh. This will install the plugin ‘libvbz_hdf_plugin.so’ in ‘ont-vbz-hdf-plugin-1.0.1-Linux’ directory located in the home directory
- then, cd to ‘ont-vbz-hdf-plugin-1.0.1-Linux’ directory and navigate all the way to the ‘plugin’ directory; get the path of the ‘plugin’ directory by running ‘pwd’, and set the path in bashrc profile in as “export HDF5_PLUGIN_PATH=/path_of_the_plugin_directory”. Note that adding the path in the $PATH variable like “export PATH=$PATH:/path_of_the_plugin_directory” does not work in this case. 



**Or, use ‘wget’**


```
wget https://github.com/nanoporetech/vbz_compression/releases/download/v1.0.1/ont-vbz-hdf-plugin-1.0.1-Linux-x86_64.tar.gz
```


then, 

```
tar -zvxf ont-vbz-hdf-plugin-1.0.1-Linux-x86_64.tar.gz
```


then, 


```
cd ont-vbz-hdf-plugin-1.0.1-Linux
```

Navigate all the way to the ‘plugin’ directory; get the path of the ‘plugin’ directory by running ‘pwd’, and add the path to the bashrc profile as 


```
export HDF5_PLUGIN_PATH=/path_of_the_plugin_directory
```


**Again, note that adding the path in the $PATH variable like “export PATH=$PATH:/path_of_the_plugin_directory” does not work in this case**




### **Now, the ‘slow5tools’ is all set. Run it as follows to convert the fast5 files to slow5 or blow5 file. More examples are here (Gamaarachchi, 2022).**



**From fast5 to blow5:**


```
slow5tools f2s fast5_dir -d blow5_dir
```


**From fast5 to slow5:**


```
slow5tools f2s --to slow5 barcode12/ -d barcode12_slow
```


**From blow5 to slow5:**

```
slow5tools view file.blow5 > file.slow5 
```



### **Notes:**

- Slow5/blow5 files are analogous to SAM/BAM files. Slow5 is the ASCII version of blow5 and blow5 is the binary version of slow5
- For data archiving and analysis, blow5 is used while slow5 is only meant for human readability.
- In terms of file size, slow5 file will be larger than blow5 version



## **Some questions and answers**



**During running slow5tools, there may be a warning saying “[search_and_warn::WARNING] slow5tools-v0.3.0: The attribute 'pore_type' is empty and will be stored in the SLOW5 header”. See the screenshot below for an example:**


<br />
<p align="center">
  <img 
    width="1216"
    height="244"
    src="https://github.com/asadprodhan/Reducing-storage-space-by-converting-Nanopore-fast5-to-slow5-using-slow5tools/blob/main/Warning.PNG"
  >
</p>

<p align = "center">
A warning message during converting the Nanopore fast5 files to blow5 files
</p>


 
This means that the fast5 file has an attribute called ‘pore_type’, which is empty. Slow5 format keeps record of all the fast5 attributes even if some might be empty. For example, ‘pore_type’ attribute in this case is empty but still included in the slow5 header. As it is an empty attribute, it is safe to ignore this warning. 



**Which information do we lose when we convert the fast5 files to slow5/blow5 files?**


By default, the conversion of fast5 to slow5/blow5 does not dispose of any information. However, manually setting “--loseless=false” when converting the fast5 files will lose information. 


**Then, how does slow5/blow5 reduce storage space?**


It reduces the storage space by reducing the space allocation and redundancy of metadata in fast5 files (Gamaarachchi et al., 2022).


**Can GPU-enabled guppy take blow5 files as input?**


Currently, guppy does not have an option to take blow5 files as input. To apply guppy, blow5 files need to be converted back to fast5 using ‘slow5tools s2f’.


**How does slow5/blow5 files reduce the run time in comparison to the fast5 file?**


Fast5 file is based on HDF5 file. HDF5 file is generally used to store large data sets. However, parallel access to the HDF5 stored data by multiple CPU threads is serialised by the HDF5 library, an only library that can read and write data in HDF5 format. This results in a longer data access time. On the other hand, slow5/blow5 files allow for parallel access to the data by multiple CPU threads, thus reducing the data access time, and ultimately reducing the total run time (Gamaarachchi et al., 2022).



## **Reference:**


Gamaarachchi, H., 2022. slow5tools. URL https://github.com/hasindu2008/slow5tools (accessed 3.23.22).


Gamaarachchi, H., Samarakoon, H., Jenner, S.P., Ferguson, J.M., Amos, T.G., Hammond, J.M., Saadat, H., Smith, M.A., Parameswaran, S., Deveson, I.W., 2022. Fast nanopore sequencing data analysis with SLOW5. Nat. Biotechnol. 1–4. https://doi.org/10.1038/s41587-021-01147-4


Loman, N.J., Quick, J., Simpson, J.T., 2015. A complete bacterial genome assembled de novo using only nanopore sequencing data. Nat. Methods 12, 733–735. https://doi.org/10.1038/nmeth.3444


