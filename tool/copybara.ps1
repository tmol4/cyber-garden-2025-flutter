[System.Environment]::SetEnvironmentVariable(
  "$$HOME",
  $Env:USERPROFILE,
  [System.EnvironmentVariableTarget]::User
);

& "C:\Program Files\Eclipse Adoptium\jdk-21.0.3.9-hotspot\bin\java.exe" -jar tool/copybara_deploy.jar copy.bara.sky;
