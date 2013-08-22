param($installPath, $toolsPath, $package, $project)

# Copy files
$rootDir = (Get-Item $installPath).parent.parent.fullname
$buildToolsSource = join-path $installPath '.build'

$deployTarget = "$rootDir"

if (!(test-path $deployTarget)) {
	mkdir $deployTarget
}


    Copy-Item $buildToolsSource $deployTarget  -Force -recurse  
    
    # Get the open solution.
    $solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
    $solutionFileName = [System.IO.Path]::GetFileName($solution.FullName)
    
    
    # update build script to point to solution
    $buildProj = "$deployTarget/.build/Build.proj"
    
    (Get-Content $buildProj) | 
    Foreach-Object {$_ -replace "Solution.sln", "../$solutionFileName"} | 
    Set-Content $buildProj
    
    #add solution items
    $buildTaskFolder = $solution.Projects | where-object { $_.ProjectName -eq ".build" } | select -first 1
    
    if(!$buildTaskFolder) {
    	$buildTaskFolder = $solution.AddSolutionFolder(".build")
    }
    
    $buildTaskFolderItems = Get-Interface $buildTaskFolder.ProjectItems ([EnvDTE.ProjectItems])
    
    Write-Host $deployTarget
    
    if (!($buildTaskFolderItems -contains "$deployTarget/.build/Build.bat")) {
        $buildTaskFolderItems.AddFromFile("$deployTarget/.build/Build.bat") 
    }
    if (!($buildTaskFolderItems -contains "$deployTarget/.build/Build.proj")) {
        $buildTaskFolderItems.AddFromFile("$deployTarget/.build/Build.proj") 
    }
    if (!($buildTaskFolderItems -contains "$deployTarget/.build/DateStampVersion.tasks")) {
        $buildTaskFolderItems.AddFromFile("$deployTarget/.build/DateStampVersion.tasks")
    }


#$buildTasksFolder = Get-Interface $buildTaskProject.Object ([EnvDTE80.SolutionFolder])
#$projectItems = Get-Interface $buildTaskProject.ProjectItems ([EnvDTE.ProjectItems])
#
#$projectItems.AddFromFile("pathToFileToAdd.txt")
#$projectFile = $buildTasksFolder.AddFromFile($fileName)