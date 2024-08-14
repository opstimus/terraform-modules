data "aws_caller_identity" "current" {}

resource "aws_sqs_queue" "main" {
  name                       = var.enable_fifo == true ? "${var.project}-${var.environment}-${var.name}.fifo" : "${var.project}-${var.environment}-${var.name}"
  fifo_queue                 = var.enable_fifo
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  max_message_size           = var.max_message_size
  delay_seconds              = var.delay_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  policy                     = var.policy
  deduplication_scope        = var.enable_fifo == true && var.enable_high_throughput == true ? "messageGroup" : ((var.enable_fifo == true && var.enable_high_throughput == false) ? "queue" : null)
  fifo_throughput_limit      = var.enable_fifo == true && var.enable_high_throughput == true ? "perMessageGroupId" : ((var.enable_fifo == true && var.enable_high_throughput == false) ? "perQueue" : null)
  sqs_managed_sse_enabled    = true
}

data "aws_iam_policy_document" "main" {
  statement {
    sid    = "Default"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.main.arn]
  }
}

resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id
  policy    = var.policy == null ? data.aws_iam_policy_document.main.json : var.policy
}


resource "aws_sqs_queue_redrive_policy" "main" {
  count     = var.enable_dlq ? 1 : 0
  queue_url = aws_sqs_queue.main.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_sqs_queue" "dlq" {
  count                     = var.enable_dlq ? 1 : 0
  name                      = var.enable_fifo == true ? "${var.project}-${var.environment}-${var.name}-dlq.fifo" : "${var.project}-${var.environment}-${var.name}-dlq"
  fifo_queue                = var.enable_fifo
  message_retention_seconds = var.message_retention_seconds_dlq
  sqs_managed_sse_enabled   = true
}

data "aws_iam_policy_document" "dlq" {
  count = var.enable_dlq ? 1 : 0
  statement {
    sid    = "Default"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["sqs:*"]
    resources = [aws_sqs_queue.dlq[0].arn]
  }
}

resource "aws_sqs_queue_policy" "dlq" {
  count     = var.enable_dlq ? 1 : 0
  queue_url = aws_sqs_queue.dlq[0].id
  policy    = var.policy == null ? data.aws_iam_policy_document.dlq[0].json : var.policy
}

resource "aws_sqs_queue_redrive_allow_policy" "main" {
  count     = var.enable_dlq ? 1 : 0
  queue_url = aws_sqs_queue.dlq[0].id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.main.arn]
  })
}
