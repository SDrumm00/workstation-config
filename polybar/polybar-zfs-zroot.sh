#
#
################################################################################
#                                                                              #
# polybar-zfs by Scott Drumm 2023                                              #
#                                                                              #
# Edit the show_name, show_health, and pool_name variables to match your needs #
#                                                                              #
################################################################################

# Show pool health (yes/no. Default: "no")
show_health="yes"

# Change pool_name to the name of the pool you want to monitor
pool_name="zroot"

# Get pool info. Do not edit.
# Pool allocation
pool_alloc=$(zpool list -o alloc $pool_name | tr -d 'ALLOC\n ')
# Total pool size
pool_size=$(zpool list -o size $pool_name | tr -d 'SIZE\n ')
# Pool health status
pool_health=$(zpool list -o health $pool_name)

# Output pool info to module
case $show_health in
  *"no"*)
    echo " $pool_alloc"
    ;;
  *"yes"*)
    case $pool_health in
      *"ONLINE"*)
        echo " $pool_alloc (Online)"
        ;;
      *"DEGRADED"*)
        echo " $pool_alloc (Degraded)"
        ;;
      *"FAULTED"*)
        echo " $pool_alloc (Faulted)"
        ;;
      *"OFFLINE"*)
        echo " $pool_alloc (Offline)"
        ;;
      *"UNAVAIL"*)
        echo " $pool_alloc (Unavailable)"
        ;;
      *"REMOVED"*)
        echo " $pool_alloc (Removed)"
        ;;
    esac
esac
