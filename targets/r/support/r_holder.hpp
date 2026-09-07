#pragma once

#include <memory>
#include <mutex>
#include <deque>
#include <string>
#include <variant>

#include <R.h>
#include <Rinternals.h>
#include <ntgcalls/ntgcalls.hpp>

namespace ntgcalls::r {

struct NTgEventRecord {
    std::string type;
    int64_t chat_id{0};
    int64_t user_id{0};
    int32_t val1{0};
    int32_t val2{0};
    int32_t val3{0};
    int64_t lval1{0};
    int64_t lval2{0};
    double dval{0.0};
    bool bval{false};
    std::string sval;
    bytes::binary bdata;
    SEXP custom_sexp{R_NilValue};
};

class NTgCallsHolder {
public:
    explicit NTgCallsHolder(std::unique_ptr<ntgcalls::NTgCalls> instance)
        : instance_(std::move(instance)) {}

    ~NTgCallsHolder() {
        instance_.reset();
    }

    ntgcalls::NTgCalls* get() const {
        return instance_.get();
    }

    void push_event(NTgEventRecord ev) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (events_.size() > 5000) {
            events_.pop_front();
        }
        events_.push_back(std::move(ev));
    }

    std::vector<NTgEventRecord> pop_events(size_t max_count = 100) {
        std::lock_guard<std::mutex> lock(mutex_);
        std::vector<NTgEventRecord> result;
        size_t count = std::min(max_count, events_.size());
        result.reserve(count);
        for (size_t i = 0; i < count; ++i) {
            result.push_back(std::move(events_.front()));
            events_.pop_front();
        }
        return result;
    }

private:
    std::unique_ptr<ntgcalls::NTgCalls> instance_;
    std::mutex mutex_;
    std::deque<NTgEventRecord> events_;
};

inline void r_ntg_finalizer(SEXP ptr) {
    if (TYPEOF(ptr) != EXTPTRSXP) {
        return;
    }
    auto* holder = static_cast<NTgCallsHolder*>(R_ExternalPtrAddr(ptr));
    if (holder) {
        delete holder;
        R_ClearExternalPtr(ptr);
    }
}

inline NTgCallsHolder* get_holder(SEXP ptr) {
    if (TYPEOF(ptr) != EXTPTRSXP) {
        Rf_errorcall(R_NilValue, "Invalid handle: expected ExternalPtr");
    }
    auto* holder = static_cast<NTgCallsHolder*>(R_ExternalPtrAddr(ptr));
    if (!holder || !holder->get()) {
        Rf_errorcall(R_NilValue, "Invalid handle: null or destroyed NTgCalls pointer");
    }
    return holder;
}

}
