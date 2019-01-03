#!/usr/bin/env bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#
# Define some useful functions to work with elassandra inside k8s
#
_e_usage() {
  echo "usage: source scripts/el-k8s-lib.sh"
  echo
  echo "required variables:"
  echo " " export APP_INSTANCE_NAME=elassandra-1
  echo " " export NAMESPACE=default
  echo
  echo "examples:"
  echo " " e_cqlsh 0 -e "DESC KEYSPACES"
  echo " " e_nodetool 1 status
  echo " " e_curl 2 localhost:9200
}

_e_require_vars() {
  if [ -n "$APP_INSTANCE_NAME" ] && [ -n "$NAMESPACE" ]; then
    return 0;
  else
    echo "error: missing variable APP_INSTANCE_NAME or NAMESPACE"
    echo
    _e_usage
    return 1
   fi
}

echo "defining function e_cqlsh(node_index, cqlsh_args...)"
e_cqlsh() {
  _e_require_vars || return 1
  node_num=${1:-0}
  shift;
  kubectl exec --namespace=$NAMESPACE -it $APP_INSTANCE_NAME-$node_num cqlsh -- "$@"
}

echo "defining function e_nodetool(node_index, nodetool_args...)"
e_nodetool() {
  _e_require_vars || return 1
  node_num=${1:-0}
  shift;
  kubectl exec --namespace=$NAMESPACE -it $APP_INSTANCE_NAME-$node_num nodetool -- "$@"
}

echo "defining function e_curl(node_index, curl_args...)"
e_curl() {
  _e_require_vars || return 1
  node_num=${1:-0}
  shift;
  kubectl exec --namespace=$NAMESPACE -it $APP_INSTANCE_NAME-$node_num curl -- "$@"
}

echo
_e_usage