#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
// #define DEBUG_LOG(msg,...)
#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)


int microseconds_sleep = 0;

void* threadfunc(void* thread_param)
{

    struct thread_data* thread_func_args = (struct thread_data*)thread_param;

    usleep(1000 * thread_func_args->m_wait_to_obtain_ms);

    pthread_mutex_lock(thread_func_args->m_mutex);
    {
        printf(" microseconds_execution %d <<>> %d \n", microseconds_sleep,
                microseconds_sleep + 1000 * (thread_func_args->m_wait_to_obtain_ms + thread_func_args->m_wait_to_release_ms));
        microseconds_sleep += 1000 * (thread_func_args->m_wait_to_obtain_ms + thread_func_args->m_wait_to_release_ms);
        usleep(1000 * thread_func_args->m_wait_to_release_ms);

    }
    pthread_mutex_unlock(thread_func_args->m_mutex);

    thread_func_args->thread_complete_success = true;

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    struct thread_data* thread_params = (struct thread_data*)malloc(sizeof(struct thread_data));
    thread_params->m_mutex = mutex;
    thread_params->m_wait_to_obtain_ms = wait_to_obtain_ms;
    thread_params->m_wait_to_release_ms = wait_to_release_ms;
    thread_params->thread_complete_success = false;
    bool result = false;
    pthread_t new_thread = 0;
    int rc = pthread_create(&new_thread, NULL, threadfunc, (void*)thread_params);
    if (rc == 0)
    {
        DEBUG_LOG("New thread: %lu", new_thread);
        *thread = new_thread;
        result = true;
    }
    else
    {
        ERROR_LOG("Error pthread_create ");
    }
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */


    return result;
}

