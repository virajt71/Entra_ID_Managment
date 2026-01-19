variable "departments" {
  description = "List of departments to create groups for"
  type        = list(string)
  default     = []
}

variable "group_prefix" {
  description = "Prefix for group names"
  type        = string
  default     = "dept"
}

variable "subscription_owner_id" {
  description = "Object ID of the subscription owner (will be made owner of all groups)"
  type        = string
  default     = ""
}

variable "users_by_department" {
  description = "Map of departments to user object IDs"
  type        = map(list(string))
  default     = {}
}

variable "group_description_template" {
  description = "Template for group descriptions"
  type        = string
  default     = "Department group for {department}"
}
