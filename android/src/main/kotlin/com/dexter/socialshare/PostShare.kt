package com.dexter.socialshare

import com.google.gson.annotations.SerializedName

data class PostShare(
        @SerializedName("message") val message: String,
        @SerializedName("phoneNumber") val phoneNumber: String?,
        @SerializedName("type") val type: String
)