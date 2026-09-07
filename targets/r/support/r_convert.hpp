#pragma once

#include <cstdint>
#include <cstring>
#include <string>
#include <vector>
#include <optional>
#include <map>
#include <memory>
#include <R.h>
#include <Rinternals.h>
#include <bytes/binary.hpp>

namespace ntgcalls::r {

inline SEXP to_r(bool v) { return Rf_ScalarLogical(v ? 1 : 0); }
inline SEXP to_r(int8_t v) { return Rf_ScalarInteger(v); }
inline SEXP to_r(uint8_t v) { return Rf_ScalarInteger(v); }
inline SEXP to_r(int16_t v) { return Rf_ScalarInteger(v); }
inline SEXP to_r(uint16_t v) { return Rf_ScalarInteger(v); }
inline SEXP to_r(int32_t v) { return Rf_ScalarInteger(v); }
inline SEXP to_r(uint32_t v) { return Rf_ScalarReal(static_cast<double>(v)); }
inline SEXP to_r(int64_t v) { return Rf_ScalarReal(static_cast<double>(v)); }
inline SEXP to_r(uint64_t v) { return Rf_ScalarReal(static_cast<double>(v)); }
inline SEXP to_r(double v) { return Rf_ScalarReal(v); }
inline SEXP to_r(const std::string& v) { return Rf_mkString(v.c_str()); }
inline SEXP to_r(const char* v) { return v ? Rf_mkString(v) : Rf_mkString(""); }
inline SEXP to_r(const bytes::binary& v) {
    SEXP raw = Rf_allocVector(RAWSXP, v.size());
    if (v.size() > 0) std::memcpy(RAW(raw), v.data(), v.size());
    return raw;
}
template<typename T> inline SEXP to_r(const std::optional<T>& v) {
    if (!v.has_value()) return R_NilValue;
    return to_r(*v);
}
template<typename T> inline SEXP to_r(const std::vector<T>& v) {
    SEXP list = Rf_allocVector(VECSXP, v.size());
    Rf_protect(list);
    for (size_t i = 0; i < v.size(); ++i) SET_VECTOR_ELT(list, i, to_r(v[i]));
    Rf_unprotect(1);
    return list;
}
inline void from_r(SEXP s, bool& out) {
    if (Rf_isLogical(s) && Rf_length(s) > 0) out = LOGICAL(s)[0] != 0;
    else if (Rf_isInteger(s) && Rf_length(s) > 0) out = INTEGER(s)[0] != 0;
    else if (Rf_isReal(s) && Rf_length(s) > 0) out = REAL(s)[0] != 0.0;
}
inline void from_r(SEXP s, int8_t& out) {
    if (Rf_isInteger(s) && Rf_length(s) > 0) out = static_cast<int8_t>(INTEGER(s)[0]);
    else if (Rf_isReal(s) && Rf_length(s) > 0) out = static_cast<int8_t>(REAL(s)[0]);
}
inline void from_r(SEXP s, uint8_t& out) {
    if (Rf_isInteger(s) && Rf_length(s) > 0) out = static_cast<uint8_t>(INTEGER(s)[0]);
    else if (Rf_isReal(s) && Rf_length(s) > 0) out = static_cast<uint8_t>(REAL(s)[0]);
}
inline void from_r(SEXP s, int16_t& out) {
    if (Rf_isInteger(s) && Rf_length(s) > 0) out = static_cast<int16_t>(INTEGER(s)[0]);
    else if (Rf_isReal(s) && Rf_length(s) > 0) out = static_cast<int16_t>(REAL(s)[0]);
}
inline void from_r(SEXP s, uint16_t& out) {
    if (Rf_isInteger(s) && Rf_length(s) > 0) out = static_cast<uint16_t>(INTEGER(s)[0]);
    else if (Rf_isReal(s) && Rf_length(s) > 0) out = static_cast<uint16_t>(REAL(s)[0]);
}
inline void from_r(SEXP s, int32_t& out) {
    if (Rf_isInteger(s) && Rf_length(s) > 0) out = INTEGER(s)[0];
    else if (Rf_isReal(s) && Rf_length(s) > 0) out = static_cast<int32_t>(REAL(s)[0]);
}
inline void from_r(SEXP s, uint32_t& out) {
    if (Rf_isReal(s) && Rf_length(s) > 0) out = static_cast<uint32_t>(REAL(s)[0]);
    else if (Rf_isInteger(s) && Rf_length(s) > 0) out = static_cast<uint32_t>(INTEGER(s)[0]);
}
inline void from_r(SEXP s, int64_t& out) {
    if (Rf_isReal(s) && Rf_length(s) > 0) out = static_cast<int64_t>(REAL(s)[0]);
    else if (Rf_isInteger(s) && Rf_length(s) > 0) out = static_cast<int64_t>(INTEGER(s)[0]);
    else if (Rf_isString(s) && Rf_length(s) > 0) out = std::stoll(CHAR(STRING_ELT(s, 0)));
}
inline void from_r(SEXP s, uint64_t& out) {
    if (Rf_isReal(s) && Rf_length(s) > 0) out = static_cast<uint64_t>(REAL(s)[0]);
    else if (Rf_isInteger(s) && Rf_length(s) > 0) out = static_cast<uint64_t>(INTEGER(s)[0]);
    else if (Rf_isString(s) && Rf_length(s) > 0) out = static_cast<uint64_t>(std::stoull(CHAR(STRING_ELT(s, 0))));
}
inline void from_r(SEXP s, double& out) {
    if (Rf_isReal(s) && Rf_length(s) > 0) out = REAL(s)[0];
    else if (Rf_isInteger(s) && Rf_length(s) > 0) out = static_cast<double>(INTEGER(s)[0]);
}
inline void from_r(SEXP s, std::string& out) {
    if (Rf_isString(s) && Rf_length(s) > 0) out = CHAR(STRING_ELT(s, 0));
}
inline void from_r(SEXP s, bytes::binary& out) {
    if (TYPEOF(s) == RAWSXP) {
        R_xlen_t len = Rf_xlength(s);
        out.resize(len);
        if (len > 0) std::memcpy(out.data(), RAW(s), len);
    }
}
template<typename T> inline void from_r(SEXP s, std::optional<T>& out) {
    if (s == R_NilValue || Rf_isNull(s) || Rf_length(s) == 0) out = std::nullopt;
    else { T val{}; from_r(s, val); out = val; }
}
template<typename T> inline void from_r(SEXP s, std::vector<T>& out) {
    out.clear();
    if (s == R_NilValue || Rf_isNull(s)) return;
    if (TYPEOF(s) == VECSXP) {
        R_xlen_t n = Rf_xlength(s);
        out.reserve(n);
        for (R_xlen_t i = 0; i < n; ++i) { T item{}; from_r(VECTOR_ELT(s, i), item); out.push_back(item); }
    } else if (Rf_length(s) > 0) { T item{}; from_r(s, item); out.push_back(item); }
}
inline SEXP get_list_element(SEXP list, const char* name) {
    if (TYPEOF(list) != VECSXP) return R_NilValue;
    SEXP names = Rf_getAttrib(list, R_NamesSymbol);
    if (names == R_NilValue) return R_NilValue;
    R_xlen_t n = Rf_xlength(list);
    for (R_xlen_t i = 0; i < n; ++i) {
        if (std::strcmp(CHAR(STRING_ELT(names, i)), name) == 0) return VECTOR_ELT(list, i);
    }
    return R_NilValue;
}

}
