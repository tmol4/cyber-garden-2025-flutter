#include "include/event_holder.h"

EventHolder* EventHolder::pinstance_{ nullptr };
std::mutex EventHolder::mutex_;

EventHolder* EventHolder::GetInstance()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (pinstance_ == nullptr)
    {
        pinstance_ = new EventHolder();
    }
    return pinstance_;
}