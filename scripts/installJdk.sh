#!/bin/sh
echo "Installing JDK!"

chmod 775 /vagrant_data/jdk-6u35-linux-x64.bin

cd /root
yes | /vagrant_data/jdk-6u35-linux-x64.bin

/bin/mv /root/jdk1.6.0_35 /opt

/bin/rm -rv /usr/bin/java
/bin/rm -rv /usr/bin/javac

/bin/ln -s /opt/jdk1.6.0_35/bin/java /usr/bin
/bin/ln -s /opt/jdk1.6.0_35/bin/javac /usr/bin
JAVA_HOME=/opt/jdk1.6.0_35
export JAVA_HOME
PATH=$PATH:$JAVA_HOME/bin
export PATH

echo "JDK Installed!"
