# Copyright 2018 WSO2, Inc. (http://wso2.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# set variables
WSO2_SERVER=wso2sp
WSO2_SERVER_VERSION=4.2.0
WSO2_SERVER_PACK=${WSO2_SERVER}-${WSO2_SERVER_VERSION}*.zip
MYSQL_CONNECTOR=mysql-connector-java-5.1.*-bin.jar
JDK_ARCHIVE=jdk-8u*-linux-x64.tar.gz
WUM_ARCHIVE=wum-1.0-linux-x64.tar.gz
WORKING_DIRECTORY=/home/vagrant
JAVA_HOME=/opt/java/
WUM_HOME=/usr/local
WUM_PATH=PATH=$PATH:/usr/local/wum/bin
CONFIGURATIONS=${WORKING_DIRECTORY}/worker/repository

# operating in non-interactive mode
export DEBIAN_FRONTEND=noninteractive

# install utility software
echo "Installing software utilities."
apt-get install unzip
echo "Successfully installed software utilities."

#setting up Java
echo "Setting up Java."
if test ! -d ${JAVA_HOME}; then
  mkdir ${JAVA_HOME};
  tar -xf ${WORKING_DIRECTORY}/${JDK_ARCHIVE} -C ${JAVA_HOME} --strip-components=1
  echo "Successfully set up Java"
fi

# set up wum
echo "Setting up WUM."
if test ! -d ${WUM_HOME}; then
  mkdir ${WUM_HOME};
  tar -xf ${WORKING_DIRECTORY}/${WUM_ARCHIVE} -C ${WUM_HOME} --strip-components=1
  echo "Successfully set up WUM."
fi

# unpack the WSO2 product pack to the working directory
echo "Setting up the ${WSO2_SERVER}-${WSO2_SERVER_VERSION} server..."
if test ! -d ${WSO2_SERVER}-${WSO2_SERVER_VERSION}; then
  unzip -q ${WORKING_DIRECTORY}/${WSO2_SERVER_PACK} -d ${WORKING_DIRECTORY}
fi
echo "Successfully set up ${WSO2_SERVER}-${WSO2_SERVER_VERSION} server"

# add the MySQL driver
echo "Copying the MySQL driver to the server pack..."
cp ${WORKING_DIRECTORY}/${MYSQL_CONNECTOR} ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/lib/${MYSQL_CONNECTOR}
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the MySQL driver to the server pack."
else
  echo "Failed to copy the MySQL driver to the server pack."
fi

# copy files with configuration changes
echo "Copying the files with configuration changes to the server pack..."

cp -TRv ${CONFIGURATIONS}/conf/ ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/conf/worker
if [ "$?" -eq "0" ];
then
  echo "Successfully copied the configuration files."
else
  echo "Failed to copy the configuration files"
fi

export JAVA_HOME
export WUM_HOME

echo "Removing configurations directories."
rm -rf ${CONFIGURATIONS}

# start the WSO2 product pack as a background service
echo "Starting ${WSO2_SERVER}-${WSO2_SERVER_VERSION}..."
nohup ${WORKING_DIRECTORY}/${WSO2_SERVER}-${WSO2_SERVER_VERSION}/wso2/worker/bin/carbon.sh &

sleep 10
