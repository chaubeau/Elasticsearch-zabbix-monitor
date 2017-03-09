#!/bin/bash
###############################################################################
#* Copyright (c) 1998, Regents of the University of California
#* All rights reserved.
#* Redistribution and use in source and binary forms, with or without
#* modification, are permitted provided that the following conditions are met:
#*
#*     * Redistributions of source code must retain the above copyright
#*       notice, this list of conditions and the following disclaimer.
#*     * Redistributions in binary form must reproduce the above copyright
#*       notice, this list of conditions and the following disclaimer in the
#*       documentation and/or other materials provided with the distribution.
#*     * Neither the name of the University of California, Berkeley nor the
#*       names of its contributors may be used to endorse or promote products
#*       derived from this software without specific prior written permission.
#*
#* THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS "AS IS" AND ANY
#* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#* DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
#* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##################################################################################
set -e
declare -r IP=$(hostname -i)
declare -r PORT=7536
declare -r  URL="http://$IP:$PORT"
declare -r  NODE_ID=$(curl -s -XGET  "$URL/_nodes/_local/stats?human&pretty"|jq ".nodes"|head -n 2|sed -n '2p'|awk -F'\"' '{print $2}')
declare -r  NODE_REG="AABBCCES"

function cluster_health(){
	local key=$1
	local cluster_url="$URL/_cluster/health?pretty=true"
	case $key in
		status)
			es_status=$(curl -s -XGET "$cluster_url"|jq ".status"|tr -d '"')
			if [ $es_status == "green" ]
			then
				echo 0
			elif [ $es_status == "yellow" ]
			then
				echo 1
			else
				echo 2
			fi	
			;;
		active_shards_percent_as_number)
			curl -s -XGET "$cluster_url"|jq ".active_shards_percent_as_number"
			;;
		shards)
			curl -s -XGET "$cluster_url"|jq ".active_shards"
			;;
		number_of_pending_tasks)
			curl -s -XGET "$cluster_url"|jq ".number_of_pending_tasks"
			;;
		relocating_shards)
			curl -s -XGET "$cluster_url"|jq ".relocating_shards"
			;;
		initializing_shards)
			curl -s -XGET "$cluster_url"|jq ".initializing_shards"
			;;
		active_primary_shards)
			curl -s -XGET "$cluster_url"|jq ".active_primary_shards"
			;;
		unassigned_shards)
			curl -s -XGET "$cluster_url"|jq ".unassigned_shards"
			;;
		*)
			exit 255
			;;
	esac
}

function cluster_state(){
	local key=$1
	local cluster_url="$URL/_cluster/stats?pretty=true"
	case $key in
		"docs_count")
			curl -s -XGET "$cluster_url"|jq ".indices.docs.count"
			;;
		"docs_deleted")
			curl -s -XGET "$cluster_url"|jq ".indices.docs.deleted"
			;;
		"number_of_nodes")
			curl -s -XGET "$cluster_url"|jq ".nodes.count.total"
			;;
		"number_of_data_nodes")
			curl -s -XGET "$cluster_url"|jq ".nodes.count.data"
			;;
		*)
			exit 255
			;;
	esac
}

# node jvm information
function node_jvm(){
	local key=$1
	local node_url="$URL/_nodes/_local/stats?human&pretty"
	case $key in
		"gc_collectors_young_count")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.gc.collectors.young.collection_count"
			;;
		"gc_collectors_young_collection_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.gc.collectors.young.collection_time_in_millis"
			;;
		"gc_collectors_old_collection_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.gc.collectors.old.collection_time_in_millis"
			;;
		"gc_collectors_old_count")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.gc.collectors.old.collection_count"
			;;
		"mem_heap_committed")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.mem.heap_committed_in_bytes"
			;;
		"mem_heap_used_percent")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.mem.heap_used_percent"
			;;
		"mem_heap_max")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.mem.heap_max_in_bytes"
			;;
		"mem_heap_used")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.mem.heap_used_in_bytes"
			;;
		"mem_non_heap_committed")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.mem.non_heap_committed_in_bytes"
			;;
		"mem_non_heap_used")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.mem.non_heap_used_in_bytes"
			;;
		"threads_count")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.threads.count"
			;;
		"threads_peak_count")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.jvm.threads.peak_count"
			;;
		*)
			exit 255
			;;
	esac

}
function node_thread_pool(){
	local key=$1
	local node_url="$URL/_nodes/_local/stats?human&pretty"
	case $key in
		"bulk_active")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.bulk.active"
			;;
		"bulk_queue")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.bulk.queue"
			;;
		"bulk_rejected")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.bulk.rejected"
			;;
		"bulk_threads")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.bulk.threads"
			;;
		"flush_active")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.flush.active"
			;;
		"flush_queue")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.flush.queue"
			;;
		"flush_threads")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.flush.threads"
			;;
		"generic_active")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.generic.active"
			;;
		"generic_queue")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.generic.queue"
			;;
		"generic_threads")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.generic.threads"
			;;
		"get_active")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.get.active"
			;;
		"get_queue")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.get.queue"
			;;
		"get_threads")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.get.threads"
			;;
		"index_active")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.index.active"
			;;
		"index_queue")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.index.queue"
			;;
		"index_threads")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.index.threads"
			;;
		"management_active")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.management.active"
			;;
		"management_queue")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.management.queue"
			;;
		"management_threads")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.management.threads"
			;;
		"refresh_active")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.refresh.active"
			;;
		"refresh_queue")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.refresh.queue"
			;;
		"refresh_threads")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.refresh.threads"
			;;
		"search_active")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.search.active"
			;;
		"search_queue")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.search.queue"
			;;
		"search_threads")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.search.threads"
			;;
		"snapshot_active")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.snapshot.active"
			;;
		"snapshot_queue")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.snapshot.queue"
			;;
		"snapshot_threads")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.thread_pool.snapshot.threads"
			;;
		*)
			exit 255
			;;
	esac
}

function node_indices(){
	local key=$1
	local node_url="$URL/_nodes/_local/stats?human&pretty"
	case $key in
		"search_fetch_current")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.search.fetch_current"
			;;
		"search_fetch_open_contexts")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.search.open_contexts"
			;;
		"search_fetch_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.search.fetch_time_in_millis"
			;;
		"search_fetch_total")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.search.fetch_total"
			;;
		"search_query_current")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.search.query_current"
			;;
		"search_query_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.search.query_time_in_millis"
			;;
		"search_query_total")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.search.query_total"
			;;
		"refresh_total")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.refresh.total"
			;;
		"refresh_total_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.refresh.total_time_in_millis"
			;;
		"store_size")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.store.size_in_bytes"
			;;
		"merges_current")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.merges.current"
			;;
		"merges_current_docs")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.merges.current_docs"
			;;
		"merges_current_size")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.merges.current_size_in_bytes"
			;;
		"merges_total")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.merges.total"
			;;
		"merges_total_docs")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.merges.total_docs"
			;;
		"merges_total_size")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.merges.total_size_in_bytes"
			;;
		"merges_total_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.merges.total_time_in_millis"
			;;
		"segments_count")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.segments.count"
			;;
		"segments_fixed_bit_set_memory_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.segments.fixed_bit_set_memory_in_bytes"
			;;
		"segments_index_writer_memory_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.segments.index_writer_memory_in_bytes"
			;;
		"segments_memory_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.segments.memory_in_bytes"
			;;
		"segments_version_map_memory_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.segments.version_map_memory_in_bytes"
			;;
		"indexing_delete_current")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.indexing.delete_current"
			;;
		"indexing_delete_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.indexing.delete_time_in_millis"
			;;
		"indexing_delete_total")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.indexing.delete_total"
			;;
		"indexing_index_current")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.indexing.index_current"
			;;
		"indexing_index_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.indexing.index_time_in_millis"
			;;
		"indexing_index_total")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.indexing.index_total"
			;;
		"get_current")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.get.current"
			;;
		"get_exists_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.get.exists_time_in_millis"
			;;
		"get_exists_total")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.get.exists_total"
			;;
		"get_missing_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.get.missing_time_in_millis"
			;;
		"get_missing_total")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.get.missing_total"
			;;
		"get_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.get.time_in_millis"
			;;
		"get_total")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.get.total"
			;;
		"flush_total")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.flush.total"
			;;
		"flush_total_time")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.flush.total_time_in_millis"
			;;
		"query_cache_total_count")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.query_cache.total_count"
			;;
		"query_cache_hit_count")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.query_cache.hit_count"
			;;
		"query_cache_miss_count")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.query_cache.miss_count"
			;;
		"query_cache_memory_size_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.query_cache.memory_size_in_bytes"
			;;
		"store_size")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.indices.store.size_in_bytes"
			;;
		
		*)
			exit 255
			;;
	esac
}

function fs(){
	local key=$1
	local node_url="$URL/_nodes/_local/stats?human&pretty"
	case $key in
		"total_available_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.fs.total.available_in_bytes"
			;;
		"total_disk_io_op")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.fs.io_stats.total.operations"
			;;
		"total_disk_io_size_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.fs.total.total_in_bytes"
			;;
		"total_disk_read_size_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.fs.io_stats.total.read_kilobytes"
			;;
		"total_disk_reads")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.fs.io_stats.total.read_operations"
			;;
		"total_disk_write_size_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.fs.io_stats.total.write_kilobytes"
			;;
		"total_disk_writes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.fs.io_stats.total.write_operations"
			;;
		"total_free_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.fs.total.free_in_bytes"
			;;
		"total_total_in_bytes")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.fs.total.total_in_bytes"
			;;
		*)
			exit 255
			;;
	esac
}

function node_http(){
	local key=$1
	local node_url="$URL/_nodes/_local/stats?human&pretty"
	case $key in
		"current_open")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.http.current_open"
			;;
		"total_opened")
			curl -s -XGET "$node_url"|sed "s/$NODE_ID/$NODE_REG/"|jq ".nodes.$NODE_REG.http.total_opened"
			;;
		*)
			exit 255
			;;
		esac
}


function main(){
	case $1 in
	 	"health")
			cluster_health $2
			;;
		"state")
			cluster_state $2
			;;
		"jvm")
			node_jvm $2
			;;
		"thread_pool")
			node_thread_pool $2
			;;
		"indices")
			node_indices $2
			;;
		"fs")
			fs $2
			;;
		"http")
			node_http $2
			;;
		*)
			exit 255
			;;
		esac

}

main $@
