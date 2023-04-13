# -- source SSL certificate
$source_ssl_pfx = ""
$source_ssl_cert = ""

# -- dest SSL directories
$Exstream_server_strssg  = "C:\Program Files\OpenText\Exstream\16.6\Server\solutions\management\config\16.6\STRSSG"
$Exstream_server_private = "C:\Program Files\OpenText\Exstream\16.6\Server\global\security\keystore\private"
$Exstream_server_auth    = "C:\Program Files\OpenText\Exstream\16.6\Server\global\security\certificatestore\authentication"
$Exstream_mgtGateway_root= "D:\ManagementGateway\16.6\root"
$Exstream_server_trusted = "C:\Program Files\OpenText\Exstream\16.6\Server\global\security\certificatestore\trusted\authorities"
$OTDS_server_conf        = "c:\Tomcat8.5\conf"

# Backup existing certificates
if (-not (test-path $Exstream_server_strssg\BKP)) {
    New-item $Exstream_server_strssg\BKP -ItemType directory
}

Copy-Item $Exstream_server_strssg -Destination $Exstream_server_strssg\BKP

if (-not (test-path $Exstream_server_private\BKP)) {
    New-item $Exstream_server_private\BKP -ItemType directory
}

Copy-Item $Exstream_server_private -Destination $Exstream_server_private\BKP

if (-not (test-path $Exstream_server_auth\BKP)) {
    New-item $Exstream_server_auth\BKP -ItemType directory
}

Copy-Item $Exstream_server_auth -Destination $Exstream_server_auth\BKP

if (-not (test-path $Exstream_mgtGateway_root\BKP)) {
    New-item $Exstream_mgtGateway_root\BKP -ItemType directory
}

Copy-Item $Exstream_mgtGateway_root -Destination $Exstream_mgtGateway_root\BKP

if (-not (test-path $Exstream_server_trusted\BKP)) {
    New-item $Exstream_server_trusted\BKP -ItemType directory
}

Copy-Item $Exstream_server_trusted -Destination $Exstream_server_trusted\BKP

# Backup configuration files
Copy-Item $Exstream_server_trusted -Destination $Exstream_server_trusted\BKP