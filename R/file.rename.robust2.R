

#This function tries to rename all paths in the `from` field to `to`
#It first tries to do file.rename() for all,and then checks that all
#pkgs are installed successfully in the to, if they are not, it flags an error
#and switches to copy-pasting
#



file.rename.robust2<-function(from,to)
  {

  #0 Decide which method to use 
    #Assume we rename
      method='renaming'
      
    #if told otherwise by cookie, copy
      if (cookie.exists("copy_instead_of_renaming")) {
        method<-'copying'
        }  

    
  #1) Rename all files at once 
    if (method=='renaming')
    {

    #1.1) Rename them
      #Ensure parent paths exist
        for (dk in dirname(to)) dir.create(dk, showWarnings = FALSE,recursive = TRUE)

      #If files already exist in destination, delete them (this will happen e.g., if switching from copying to renaming method)
      #a pkg may exist in groundhog's library and it is now localy, renaming will generate a warning
        for (to.k in to)
        {
          if (dir.exists(to.k)) unlink(to.k,recursive = TRUE)
          
        }
        
      #Ensure from exists  
		  missing.dir <-from[!dir.exists(from)]
          if (length(missing.dir)>0) {
            gstop(paste0("These packages were expected but not found:\n",pasteN(missing.dir)))
          }
      #Rename
          file.rename(from , to)
      
    #1.2) Verify 
      outcome.rename <- basename(to) %in% data.frame(utils::installed.packages(dirname(to)),
                                                     row.names = NULL, stringsAsFactors = FALSE)$Package
      
    #1.3) If failed, stop
      if (!all(outcome.rename)) {
              
        #Draft message
            msg <-paste0("Will switch to slower 'copying-and-deleting' method going forward.\n",
                         "`help(`try.renaming.method.again()` gives additional information.")
               
          
        #If not copied, similar message, stop trying the renaming method
              save.cookie("copy_instead_of_renaming")
        
        #failure message
            gstop(format_msg(msg))  
            
          }  
  

    }#End if renaming
    
    
 #-------------------------------------   
    
    #2 METHOD=COPYING
    
      if (method=="copying")
      {

      #2.1 Console ...k feedback if more than 5
        n_to <- length(to)
        if (n_to > 5) {
          cat('\n')  
          message1("Will now copy ",n_to," packages to ",dirname(dirname(to[1])))
          }
      #2.2 Loop over files to copy
        for (k in 1:n_to)
        {
           #Show "...k"
                if (k%%10==1) cat('\n')         #print up to -10 per row
                if (length(to)>5) cat('...',k)  #show how far along we are
                
          
          #Assume we will copy
                skip.copy <- FALSE
              
        #2.3 Decide to skip, if destination already has same MD5 version
            if (dir.exists(to[k])) {
              
              
              #Get MD5s for the DESCRIPTION files #Utils.R #64
                md5.from <- get.md5(from[k])
                md5.to   <- get.md5(to[k])
                
              #If match skip
                if (md5.from==md5.to) skip.copy <- TRUE
                } 
         
         
          
        #2.4 Copy if destination does not have it
              if (skip.copy==FALSE)
              {
              #Ensure `to` directory exist
                dir.create(to[k] , recursive = TRUE,showWarnings = FALSE)
        
              #Copy 
                outcome=file.copy(from[k],dirname(to[k]),recursive = TRUE) 
              
              #Verify copy
                  if (outcome!=TRUE) {
                    msg<-paste0("Failed copying '" , from[k] , "' to '" , to[k] , "'")
                    gstop(msg)
                  } #End verification
              } #End 2.4
        
        
         #2.5 Delete when copying form local, via _PURGE if FROM is 
              
              #Local path as recorded on .pkg load
                 local_path <- .pkgenv[['default_libpath']][1]
                  
              #Check if local path contains the name of .libpaths()[1] 
                 from_is_local <- (regexpr(local_path, from[k])[[1]]>=1)
                 

              #If local, delete via purge 
                  if (from_is_local==TRUE) purge.pkg_path(from[k]) #utils #65
        } #end loop
        
    #Skip line in console at the end if we showed ...k
      if (n_to > 5) cat('\n\n')          
        
    } #End of copying method

  
} #End function