# Configuring Nextflow

Depending on your setup you'll have to adapt the default nextflow.config file.

## Executor
You can use the executor configurations as is or tweak them to your own requirements.
```
executor {
    $sge {
      queueSize = 1000
      pollInterval = '30sec'
      queueStatInterval = '5min'
    }
    $slurm {
      queueSize = 1000
      pollInterval = '30sec'
      queueStatInterval = '5min'
    }
}
```
## Profiles
We've included (and test) a profile for an sge and a slurm environment. You'll probably have to adjust options like 'queue' and 'clusterOptions' to suit your own environment.

```
profiles {
  sge {
    process.executor = 'sge'
    process.queue = 'all.q' <- change this to your own queue
    process.clusterOptions = '-P cog_bioinf ' <- change this to your own specific cluster options
  }

  slurm {
    process.executor = 'slurm'
    process.queue = 'cpu' <- change this to your own queue
  }
}
```
## Reports
You can use these defaults as is or switch off specific reporting modules by setting enabled to 'false'.
```
report {
  enabled = true
  file = "$params.out_dir/log/nextflow_report.html"
}

trace {
  enabled = true
  file = "$params.out_dir/log/nextflow_trace.txt"
  fields = 'task_id,hash,native_id,process,tag,name,status,exit,module,container,cpus,time,disk,memory,attempt,submit,start,complete,duration,realtime,queue,%cpu,%mem,rss,vmem,peak_rss,peak_vmem,rchar,wchar,syscr,syscw,read_bytes,write_bytes,vol_ctxt,inv_ctxt'
}

timeline {
  enabled = true
  file = "$params.out_dir/log/nextflow_timeline.html"

}
```
## Singularity
This workflow requires Singularity and depending on your local setup you'll have to change the runOptions & cacheDir options.
```
singularity {
  enabled = true
  autoMounts = true
  runOptions = '-B /hpc -B $TMPDIR:$TMPDIR' <- Mount directories /hpc & $TMPDIR inside the Singularity container 
  cacheDir = '/hpc/local/CentOS7/cog_bioinf/singularity_cache' <- Store downloaded singularity images here
}
```
## Cleanup
Clean up the working directory , set to either true or false. Setting it to false is usefull for debugging purposes.

```
cleanup = true
```
