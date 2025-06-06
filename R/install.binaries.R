#This function installs all binaries passed on in a a snowball, if something is not a binary it will
#be dropped



################################################################################

 install.binaries <- function(snowball,cores)
   {
      
      #1  Directory for downloaded zips temp 
          temp_path <- paste0(get.groundhog.folder() ,"/temp/")
          dir.create(temp_path,showWarnings = FALSE,recursive = TRUE) #create temp again
       
    
      #1.5 Drop non-binaries and already installed
          snowball <- snowball[snowball$from %in% c("CRAN","GRAN"),]
          snowball <- snowball[snowball$installed == FALSE,]
      
          snowball$GRAN.date=as.DateYMD(snowball$GRAN.date)
          
      #1.6 early return if nothing to install
          snowball$success = snowball$installed
          if (nrow(snowball)==0) return(snowball)
      
                        
      #2 Make  URLs for downloading and file-paths for saving
        #2.0 Common beginning of URL
          #CRAN      
            repos     <- as.character(getOption("repos"))
            url.cran  <- utils::contrib.url(repos,type='binary')
            
          #GRAN
            os  <- get.os()
            r.version <- get.r.majmin()
            url.wasabi <- paste0("https://gran.groundhogr.com/", os , "/", r.version, "/")
    
        #2.1 File extension
            if (os=='windows') ext <- 'zip'
            if (os!='windows') ext <- 'tgz'
        
        #2.2 Finalize URL with each file name
            url.files <- ifelse(snowball$from=='CRAN',
                                  paste0(url.cran,                       "/", snowball$pkg_vrs , "." , ext),
                                  paste0(url.wasabi, snowball$GRAN.date, "/", snowball$pkg_vrs , "." , ext))
            
        #2.3 Local name for saving
            zip.files <-file.path(temp_path,basename(url.files))
            
            
        #3 DOWNLOAD
            
          #3.1 Message
            n.cran <- sum(snowball$from=="CRAN")
            n.gran <- sum(snowball$from=="GRAN")
            n.tot <- n.gran+n.cran
            messagek <- message2
            if (n.tot==1) messagek <- message1
            
            if (n.cran>0 & n.gran>0)  messagek("Will now download ",n.cran, " packages from CRAN, and ",n.gran," from GRAN")
            if (n.cran>0 & n.gran==0) messagek("Will now download ",n.cran, " packages from CRAN")
            if (n.cran==0 & n.gran>0) messagek("Will now download ",n.gran, " packages from GRAN")

            
          #3.2 Set higher limit for download time (return to default in #7 below)
            time.out.before <- getOption("timeout")
            options(timeout = max(400, time.out.before))
            
          #3.3 Simultaneous libcurl download (if available)
            
              if (capabilities("libcurl")==TRUE & cores!=1)  #does this user have libcurl available?
              {
              #Total number
                n.tot <- n.cran+n.gran
                
              #Per batch
                batch.size = n.tot
                if (n.tot >= 20) batch.size=10
                if (n.tot >= 40) batch.size=20
                
              #Message about batches
                if (n.tot==batch.size &  n.tot>1)  message2('The ',n.tot,' packages will be downloaded simultaneously in a single batch')
                if (n.tot > batch.size & n.tot>1)  message2('The ',n.tot,' packages will be downloaded in batches of ',batch.size)
                
              #Download them all
                download.files.in_batches(url.files , zip.files , batch.size=batch.size)   
                #util.R function #53
                
                
              } else {
              
          #3.4 Sequential download if no libcurl or something fails
              
               for (k in 1:length(url.files))
                {
                message2("Will download sequentially, one at a time, because 'libcurl' is not available.")
                message1("    Downloading ",k," of ",length(url.files))
                
                try(utils::download.file(url.files[k], zip.files[k]))
                
                } #End loop downloading
            
              } #End else
              

        #4 Unzip / install
            
            #4.0 Subset that did download
              downloaded.TF <- file.exists(zip.files)              
              zip.files     <- zip.files[downloaded.TF]

            #4.1 How many zip files? For early return or msg of # to be installed
              n.zip <- length(zip.files)
              
              #Early return if n=0
                if (n.zip==0) return(snowball)
              
              #Messge # to install 
                if (n.zip > 1) message2("Will now install ",n.zip, " packages:")
            
                  #Use n>1 rather than n>0,because with just 1 pkg msg is redundant
              
            #4.2 Sort alphabetically by package name
               j <- order(basename(zip.files))
               zip.files <- zip.files[j]
              
            #4.3 Unzip all files found
              for (k.zip in 1:n.zip)
              {
                
                #Short name
                  zk <- zip.files[k.zip]
      
                #Extension
                  ext <- tools::file_ext(zk)
        
                #Find installation path in snowball
                  pkg.k      <- get.pkg(basename(zk))
                  k.snowball <- match(pkg.k , snowball$pkg)
                  outfile    <- snowball$installation.path[k.snowball]
                
                #Show size so big files are understandably slower
				          size <- filesize_format(file.size(zk))
                  message1('     Installing ',k.zip,' of ',n.zip,': ',basename(zk)," (",size,")")
                

                #Unzip  
                  if (ext=="zip") unzip2(zk, exdir=outfile) #See utils.r #72 - included try() error
                  if (ext!="zip") untar2(zk, exdir=outfile)  
					
          
				#Delete it
					unlink(zk)
             
              } #End of loop
              
          
      #5 Verify installation
          ip <- data.frame(utils::installed.packages(snowball$installation.path),row.names=NULL,stringsAsFactors = FALSE)      
          
          #Create pkg_vrs entry
            #If nothing installed that was supposed to, you get an error when adding pkg_vrs... so we check first if anything did install
              if (nrow(ip)>0)
              {
              ip$pkg_vrs <- paste0(ip$Package,"_",ip$Version)
              snowball$success <- snowball$pkg_vrs %in% ip$pkg_vrs
              
              } else {
                
              snowball$success=0  
              }
                

      #7 Return timeout
          options(timeout=time.out.before)
        
      #9 Output
          return(snowball)
          #note: if a non-binary was included in snowball, it will not appear here

    }

   
 