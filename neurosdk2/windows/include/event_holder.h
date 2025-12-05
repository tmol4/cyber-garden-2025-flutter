#ifndef FLUTTER_PLUGIN_EVENT_HOLDER_H_
#define FLUTTER_PLUGIN_EVENT_HOLDER_H_
#include <mutex>
#include <flutter/event_sink.h>

class EventHolder
{
private:
    static EventHolder* pinstance_;
    static std::mutex mutex_;

protected:
    EventHolder()
    {
    }
    ~EventHolder() {}

public:
    EventHolder(EventHolder& other) = delete;
    void operator=(const EventHolder&) = delete;

    static EventHolder* GetInstance();

    std::unique_ptr<flutter::EventSink<>> scannerEventSink = nullptr;

    std::unique_ptr<flutter::EventSink<>> battPowerEventSink = nullptr;
    std::unique_ptr<flutter::EventSink<>> stateEventSink = nullptr;

    std::unique_ptr<flutter::EventSink<>> signalEventSink = nullptr;
    std::unique_ptr<flutter::EventSink<>> resistEventSink = nullptr;

    std::unique_ptr<flutter::EventSink<>> callibriRespirationEventSink = nullptr;
    std::unique_ptr<flutter::EventSink<>> callibriElectrodeStateEventSink = nullptr;
    std::unique_ptr<flutter::EventSink<>> callibriEnvelopeEventSink = nullptr;
    std::unique_ptr<flutter::EventSink<>> quaternionEventSink = nullptr;

    std::unique_ptr<flutter::EventSink<>> memsEventSink = nullptr;

    std::unique_ptr<flutter::EventSink<>> fpgEventSink = nullptr;

    std::unique_ptr<flutter::EventSink<>> ampModeEventSink = nullptr;


};


#endif  // FLUTTER_PLUGIN_EVENT_HOLDER_H_